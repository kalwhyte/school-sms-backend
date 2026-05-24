// // import { Injectable } from '@nestjs/common';

// // @Injectable()
// // export class Report-cardsHelperService {}import { getGrade, getRemark } from '../utils/gradeUtils';
// import { BadRequestException } from '@nestjs/common';
// import { Injectable } from '@nestjs/common/decorators/core/injectable.decorator';
// import { PrismaService } from '../../../infrastructure/database/prisma.service';
// import { Term } from '@prisma/client';
// import {
//   SubjectResult,
//   ScoreWithAssessment,
//   getGrade,
//   getRemark,
// } from '../interfaces/index.interface';

// @Injectable()
// export class ReportCardHelperService {
//   constructor(private readonly prisma: PrismaService) {}

//   // ─────────────────────────────────────────────
//   // PRIVATE — core aggregation
//   // ─────────────────────────────────────────────
//   async buildReportCard(
//     studentId: string,
//     classId: string,
//     term: Term,
//     academicYear: string,
//   ) {
//     const results = await this.getStudentScoresForTerm(
//       studentId,
//       classId,
//       term,
//       academicYear,
//     );

//     if (results.length === 0) {
//       throw new BadRequestException(
//         'No scores found for this student in the given term and academic year.',
//       );
//     }

//     const summary = this.computeSummary(results);
//     const attendanceSnapshot = await this.getStudentAttendanceSnapshot(
//       studentId,
//       term,
//       academicYear,
//     );

//     const classRankings = await this.computeClassRankings(
//       classId,
//       term,
//       academicYear,
//     );
//     const studentRank =
//       classRankings.find((r) => r.studentId === studentId)?.rank || null;

//     const reportCard = await this.prisma.reportCard.upsert({
//       where: {
//         studentId_term_academicYear: { studentId, term, academicYear },
//       },
//       update: {
//         classId,
//         generatedAt: new Date(),
//         isPublished: false,
//         subjectResults: results, // Store subject results
//         summaryData: summary, // Store summary data
//         attendanceSnapshot: attendanceSnapshot, // Store attendance snapshot
//         position: studentRank, // Store student's position
//       },
//       create: {
//         studentId,
//         classId,
//         term,
//         academicYear,
//         isPublished: false,
//         generatedAt: new Date(),
//         subjectResults: results, // Store subject results
//         summaryData: summary, // Store summary data
//         attendanceSnapshot: attendanceSnapshot, // Store attendance snapshot
//         position: studentRank, // Store student's position
//       },
//     });

//     return {
//       reportCardId: reportCard.id,
//       studentId,
//       classId,
//       term,
//       academicYear,
//       generatedAt: reportCard.generatedAt,
//       results, // Still return for immediate use
//       summary, // Still return for immediate use
//       attendanceSnapshot,
//       position: studentRank,
//     };
//   }

//   async getStudentScoresForTerm(
//     studentId: string,
//     classId: string,
//     term: Term,
//     academicYear: string,
//   ): Promise<SubjectResult[]> {
//     const subjects = await this.prisma.subject.findMany({
//       where: { classId },
//       select: { id: true, name: true, isCore: true },
//     });

//     // Explicit select so TypeScript knows the shape — avoids unsafe member access
//     const scores: ScoreWithAssessment[] = await this.prisma.score.findMany({
//       where: {
//         studentId,
//         assessment: { subject: { classId }, term, academicYear },
//       },
//       include: {
//         assessment: {
//           select: {
//             id: true,
//             title: true,
//             type: true,
//             maxScore: true,
//             date: true,
//             subjectId: true,
//             term: true,
//             academicYear: true,
//           },
//           // score: true,
//           // assessment: {
//           //   select: {
//           //     id: true,
//           //     title: true,
//           //     type: true,
//           //     maxScore: true,
//           //     date: true,
//           //     subjectId: true,
//           //     term: true, // Added
//           //     academicYear: true, // Added
//           //   },
//           // },
//         },
//       },
//     });

//     const results: SubjectResult[] = [];

//     for (const subject of subjects) {
//       const subjectScores = scores.filter(
//         (s) => s.assessment.subjectId === subject.id,
//       );

//       if (subjectScores.length === 0) continue;

//       const totalScore = subjectScores.reduce(
//         (sum, s) => sum + Number(s.score),
//         0,
//       );
//       const totalMax = subjectScores.reduce(
//         (sum, s) => sum + Number(s.assessment.maxScore),
//         0,
//       );
//       const percentage =
//         totalMax > 0
//           ? Math.round((totalScore / totalMax) * 100 * 100) / 100
//           : 0;

//       results.push({
//         subjectId: subject.id,
//         subjectName: subject.name,
//         isCore: subject.isCore,
//         assessments: subjectScores.map((s) => ({
//           id: s.assessment.id,
//           title: s.assessment.title,
//           type: s.assessment.type,
//           score: Number(s.score),
//           maxScore: Number(s.assessment.maxScore),
//           percentage:
//             Math.round(
//               (Number(s.score) / Number(s.assessment.maxScore)) * 100 * 100,
//             ) / 100,
//         })),
//         total: { score: totalScore, maxScore: totalMax, percentage },
//         grade: getGrade(percentage),
//         remark: getRemark(percentage),
//       });
//     }

//     return results;
//   }

//   computeSummary(results: SubjectResult[]) {
//     const totalScore = results.reduce((sum, s) => sum + s.total.score, 0);
//     const totalMax = results.reduce((sum, s) => sum + s.total.maxScore, 0);
//     const average =
//       totalMax > 0 ? Math.round((totalScore / totalMax) * 100 * 100) / 100 : 0;
//     const passed = results.filter((s) =>
//       ['A1', 'B2', 'B3', 'C4', 'C5', 'C6'].includes(s.grade),
//     ).length;

//     return {
//       totalSubjects: results.length,
//       totalScore,
//       totalMax,
//       average,
//       overallGrade: getGrade(average),
//       overallRemark: getRemark(average),
//       subjectsPassed: passed,
//       subjectsFailed: results.length - passed,
//     };
//   }

//   /**
//    * Retrieves and summarizes a student's attendance for a given term and academic year.
//    * @param studentId The ID of the student.
//    * @param term The academic term.
//    * @param academicYear The academic year.
//    * @returns An object containing total days, days present, days absent, and attendance percentage.
//    */
//   private async getStudentAttendanceSnapshot(
//     studentId: string,
//     term: Term,
//     academicYear: string,
//   ) {
//     const attendanceRecords = await this.prisma.attendance.findMany({
//       where: {
//         studentId,
//         term,
//         academicYear,
//       },
//       select: {
//         status: true,
//       },
//     });

//     const totalDays = attendanceRecords.length;
//     const daysPresent = attendanceRecords.filter(
//       (record) => record.status === 'present',
//     ).length;
//     const daysAbsent = attendanceRecords.filter(
//       (record) => record.status === 'absent',
//     ).length;
//     // Extend with other statuses like 'LATE', 'EXCUSED' if needed

//     const percentage =
//       totalDays > 0
//         ? Math.round((daysPresent / totalDays) * 100 * 100) / 100
//         : 0;

//     return {
//       totalDays,
//       daysPresent,
//       daysAbsent,
//       percentage,
//     };
//   }

//   /**
//    * Computes the rankings for all students in a specific class for a given term and academic year.
//    * @param classId The ID of the class.
//    * @param term The academic term.
//    * @param academicYear The academic year.
//    * @returns An array of students with their average scores and ranks.
//    */
//   private async computeClassRankings(
//     classId: string,
//     term: Term,
//     academicYear: string,
//   ) {
//     const studentsInClass = await this.prisma.student.findMany({
//       where: { classId },
//       select: { id: true },
//     });

//     const studentAverages: { studentId: string; average: number }[] = [];

//     for (const student of studentsInClass) {
//       const studentResults = await this.getStudentScoresForTerm(
//         student.id,
//         classId,
//         term,
//         academicYear,
//       );
//       if (studentResults.length > 0) {
//         const studentSummary = this.computeSummary(studentResults);
//         studentAverages.push({
//           studentId: student.id,
//           average: studentSummary.average,
//         });
//       } else {
//         // If no scores, treat average as 0 for ranking purposes
//         studentAverages.push({ studentId: student.id, average: 0 });
//       }
//     }

//     // Sort students by average in descending order
//     studentAverages.sort((a, b) => b.average - a.average);

//     // Assign ranks, handling ties (students with same average get same rank)
//     const rankedStudents: {
//       studentId: string;
//       average: number;
//       rank: number;
//     }[] = [];
//     let currentRank = 1;
//     for (let i = 0; i < studentAverages.length; i++) {
//       if (
//         i > 0 &&
//         studentAverages[i].average < studentAverages[i - 1].average
//       ) {
//         currentRank = i + 1;
//       }
//       rankedStudents.push({ ...studentAverages[i], rank: currentRank });
//     }

//     return rankedStudents;
//   }
// }

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
