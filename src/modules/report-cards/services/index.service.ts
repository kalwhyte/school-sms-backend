import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../../../infrastructure/database/prisma.service';
import { Term } from '@prisma/client';
import {
  SubjectResult,
  ScoreWithAssessment,
  getGrade,
  getRemark,
} from '../interfaces/index.interface';

@Injectable()
export class ReportCardHelperService {
  constructor(private readonly prisma: PrismaService) {}

  // ─────────────────────────────────────────────
  // BUILD — core aggregation + upsert
  // ─────────────────────────────────────────────
  async buildReportCard(
    studentId: string,
    classId: string,
    term: Term,
    academicYear: string,
  ) {
    const results = await this.getStudentScoresForTerm(
      studentId,
      classId,
      term,
      academicYear,
    );

    if (results.length === 0) {
      throw new BadRequestException(
        'No scores found for this student in the given term and academic year.',
      );
    }

    const summary = this.computeSummary(results);

    // Attendance snapshot — filter by classId + date range not available,
    // so we count all attendance records for this student in this class
    const attendanceSnapshot = await this.getAttendanceSnapshot(
      studentId,
      classId,
    );

    // Class position — rank among all students in the class for this term
    const { position, totalStudentsInClass } = await this.computePosition(
      studentId,
      classId,
      term,
      academicYear,
      summary.average,
    );

    const reportCard = await this.prisma.reportCard.upsert({
      where: {
        studentId_term_academicYear: { studentId, term, academicYear },
      },
      update: {
        classId,
        generatedAt: new Date(),
        isPublished: false,
        // ── New fields ────────────────────────────
        classPosition: position,
        totalStudentsInClass,
        totalScore: summary.totalScore,
        averageScore: summary.average,
        attendanceDaysPresent: attendanceSnapshot.daysPresent,
        attendanceDaysAbsent: attendanceSnapshot.daysAbsent,
        attendancePercentage: attendanceSnapshot.percentage,
      },
      create: {
        studentId,
        classId,
        term,
        academicYear,
        isPublished: false,
        generatedAt: new Date(),
        classPosition: position,
        totalStudentsInClass,
        totalScore: summary.totalScore,
        averageScore: summary.average,
        attendanceDaysPresent: attendanceSnapshot.daysPresent,
        attendanceDaysAbsent: attendanceSnapshot.daysAbsent,
        attendancePercentage: attendanceSnapshot.percentage,
      },
    });

    return {
      reportCardId: reportCard.id,
      studentId,
      classId,
      term,
      academicYear,
      generatedAt: reportCard.generatedAt,
      classPosition: position,
      totalStudentsInClass,
      results,
      summary,
      attendanceSnapshot,
    };
  }

  // ─────────────────────────────────────────────
  // SCORES — aggregate by subject for a term
  // ─────────────────────────────────────────────
  async getStudentScoresForTerm(
    studentId: string,
    classId: string,
    term: Term,
    academicYear: string,
  ): Promise<SubjectResult[]> {
    const subjects = await this.prisma.subject.findMany({
      where: { classId },
      select: { id: true, name: true, isCore: true },
    });

    const scores: ScoreWithAssessment[] = await this.prisma.score.findMany({
      where: {
        studentId,
        assessment: { subject: { classId }, term, academicYear },
      },
      include: {
        assessment: {
          select: {
            id: true,
            title: true,
            type: true,
            maxScore: true,
            date: true,
            subjectId: true,
            term: true,
            academicYear: true,
          },
        },
      },
    });

    const results: SubjectResult[] = [];

    for (const subject of subjects) {
      const subjectScores = scores.filter(
        (s) => s.assessment.subjectId === subject.id,
      );

      if (subjectScores.length === 0) continue;

      const totalScore = subjectScores.reduce(
        (sum, s) => sum + Number(s.score),
        0,
      );
      const totalMax = subjectScores.reduce(
        (sum, s) => sum + Number(s.assessment.maxScore),
        0,
      );
      const percentage =
        totalMax > 0
          ? Math.round((totalScore / totalMax) * 100 * 100) / 100
          : 0;

      results.push({
        subjectId: subject.id,
        subjectName: subject.name,
        isCore: subject.isCore,
        assessments: subjectScores.map((s) => ({
          id: s.assessment.id,
          title: s.assessment.title,
          type: s.assessment.type,
          score: Number(s.score),
          maxScore: Number(s.assessment.maxScore),
          percentage:
            Math.round(
              (Number(s.score) / Number(s.assessment.maxScore)) * 100 * 100,
            ) / 100,
        })),
        total: { score: totalScore, maxScore: totalMax, percentage },
        grade: getGrade(percentage),
        remark: getRemark(percentage),
      });
    }

    return results;
  }

  // ─────────────────────────────────────────────
  // SUMMARY — totals across all subjects
  // ─────────────────────────────────────────────
  computeSummary(results: SubjectResult[]) {
    const totalScore = results.reduce((sum, s) => sum + s.total.score, 0);
    const totalMax = results.reduce((sum, s) => sum + s.total.maxScore, 0);
    const average =
      totalMax > 0 ? Math.round((totalScore / totalMax) * 100 * 100) / 100 : 0;
    const passed = results.filter((s) =>
      ['A1', 'B2', 'B3', 'C4', 'C5', 'C6'].includes(s.grade),
    ).length;

    return {
      totalSubjects: results.length,
      totalScore,
      totalMax,
      average,
      overallGrade: getGrade(average),
      overallRemark: getRemark(average),
      subjectsPassed: passed,
      subjectsFailed: results.length - passed,
    };
  }

  // ─────────────────────────────────────────────
  // ATTENDANCE SNAPSHOT
  // Attendance has no term/academicYear — count all records for student in class
  // ─────────────────────────────────────────────
  private async getAttendanceSnapshot(studentId: string, classId: string) {
    const records = await this.prisma.attendance.findMany({
      where: { studentId, classId },
      select: { status: true },
    });

    const totalDays = records.length;
    const daysPresent = records.filter((r) => r.status === 'present').length;
    const daysAbsent = records.filter((r) => r.status === 'absent').length;
    const daysLate = records.filter((r) => r.status === 'late').length;
    const daysExcused = records.filter((r) => r.status === 'excused').length;
    const percentage =
      totalDays > 0
        ? Math.round(((daysPresent + daysLate) / totalDays) * 100 * 100) / 100
        : 0;

    return {
      totalDays,
      daysPresent,
      daysAbsent,
      daysLate,
      daysExcused,
      percentage,
    };
  }

  // ─────────────────────────────────────────────
  // CLASS POSITION — rank student among classmates
  // ─────────────────────────────────────────────
  private async computePosition(
    studentId: string,
    classId: string,
    term: Term,
    academicYear: string,
    studentAverage: number,
  ): Promise<{ position: number | null; totalStudentsInClass: number }> {
    const classStudents = await this.prisma.student.findMany({
      where: { classId, isActive: true },
      select: { id: true },
    });

    const totalStudentsInClass = classStudents.length;
    if (totalStudentsInClass === 0)
      return { position: null, totalStudentsInClass: 0 };

    // Count how many students scored strictly higher than this student
    let studentsAbove = 0;
    for (const s of classStudents) {
      if (s.id === studentId) continue;
      const theirResults = await this.getStudentScoresForTerm(
        s.id,
        classId,
        term,
        academicYear,
      );
      if (theirResults.length === 0) continue;
      const theirSummary = this.computeSummary(theirResults);
      if (theirSummary.average > studentAverage) studentsAbove++;
    }

    return {
      position: studentsAbove + 1,
      totalStudentsInClass,
    };
  }
}
