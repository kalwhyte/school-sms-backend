import {
  Injectable,
  NotFoundException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../../infrastructure/database/prisma.service';
import {
  CreateFeeStructureDto,
  UpdateFeeStructureDto,
  FeeStructureQueryDto,
  CreateBursaryApprovalDto,
  BursaryQueryDto,
  CreateExpenseDto,
  ExpenseQueryDto,
} from './dto/create-fees.dto';

@Injectable()
export class FeesService {
  private readonly logger = new Logger(FeesService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ═══════════════════════════════════════════════════════════
  // FEE STRUCTURES
  // ═══════════════════════════════════════════════════════════

  async createFeeStructure(schoolId: string, dto: CreateFeeStructureDto) {
    // Verify class belongs to school
    const cls = await this.prisma.class.findFirst({
      where: { id: dto.classId, schoolId },
      select: { id: true, name: true, arm: true },
    });
    if (!cls) throw new NotFoundException('Class not found in this school.');

    // Enforce unique per class/term/year
    const existing = await this.prisma.feeStructure.findFirst({
      where: {
        classId: dto.classId,
        term: dto.term,
        academicYear: dto.academicYear,
      },
    });
    if (existing) {
      throw new ConflictException(
        `A fee structure for ${cls.name}${cls.arm} — ${dto.term} term ${dto.academicYear} already exists.`,
      );
    }

    const feeStructure = await this.prisma.feeStructure.create({
      data: {
        schoolId,
        classId: dto.classId,
        term: dto.term,
        academicYear: dto.academicYear,
        amount: dto.amount,
        description: dto.description ?? null,
      },
      include: {
        class: { select: { id: true, name: true, arm: true } },
      },
    });

    this.logger.log(
      `Fee structure created: ${cls.name}${cls.arm} ${dto.term}/${dto.academicYear} — ₦${dto.amount}`,
    );
    return feeStructure;
  }

  async findAllFeeStructures(schoolId: string, query: FeeStructureQueryDto) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { schoolId };
    if (query.term) where.term = query.term;
    if (query.academicYear) where.academicYear = query.academicYear;
    if (query.classId) where.classId = query.classId;

    const [data, total] = await Promise.all([
      this.prisma.feeStructure.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ academicYear: 'desc' }, { term: 'asc' }],
        include: {
          class: { select: { id: true, name: true, arm: true } },
        },
      }),
      this.prisma.feeStructure.count({ where }),
    ]);

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async updateFeeStructure(
    schoolId: string,
    feeStructureId: string,
    dto: UpdateFeeStructureDto,
  ) {
    const fs = await this.prisma.feeStructure.findFirst({
      where: { id: feeStructureId, schoolId },
    });
    if (!fs) throw new NotFoundException('Fee structure not found.');

    return this.prisma.feeStructure.update({
      where: { id: feeStructureId },
      data: {
        ...(dto.amount !== undefined && { amount: dto.amount }),
        ...(dto.description !== undefined && { description: dto.description }),
      },
      include: {
        class: { select: { id: true, name: true, arm: true } },
      },
    });
  }

  // ═══════════════════════════════════════════════════════════
  // STUDENT FEE LEDGER
  // ═══════════════════════════════════════════════════════════

  async getStudentLedger(schoolId: string, studentId: string) {
    const student = await this.prisma.student.findFirst({
      where: { id: studentId, schoolId },
      select: {
        id: true,
        fullName: true,
        admissionNumber: true,
        currentClass: { select: { id: true, name: true, arm: true } },
      },
    });
    if (!student) throw new NotFoundException('Student not found.');

    const ledgers = await this.prisma.studentFeeLedger.findMany({
      where: { studentId, schoolId },
      orderBy: [{ academicYear: 'desc' }, { term: 'asc' }],
    });

    const totalOwed = ledgers.reduce((sum, l) => sum + Number(l.totalOwed), 0);
    const totalPaid = ledgers.reduce((sum, l) => sum + Number(l.totalPaid), 0);
    const totalBalance = ledgers.reduce((sum, l) => sum + Number(l.balance), 0);

    return {
      student,
      summary: {
        totalOwed,
        totalPaid,
        totalBalance,
        isInDebt: totalBalance > 0,
      },
      ledger: ledgers.map((l) => ({
        id: l.id,
        term: l.term,
        academicYear: l.academicYear,
        totalOwed: Number(l.totalOwed),
        totalPaid: Number(l.totalPaid),
        balance: Number(l.balance),
        lastUpdated: l.lastUpdated,
      })),
    };
  }

  // ─── Internal: upsert ledger after payment or bursary ─────────────────────
  async syncLedger(
    studentId: string,
    schoolId: string,
    term: string,
    academicYear: string,
  ) {
    // Sum all successful payments for this student/term/year
    const payments = await this.prisma.payment.aggregate({
      where: {
        studentId,
        schoolId,
        term: term as never,
        academicYear,
        status: 'success',
      },
      _sum: { amount: true },
    });

    // Sum bursary discounts
    const bursaries = await this.prisma.bursaryApproval.aggregate({
      where: { studentId, schoolId, term: term as never, academicYear },
      _sum: { discountAmount: true },
    });

    // Get fee structure for student's current class
    const student = await this.prisma.student.findUnique({
      where: { id: studentId },
      select: { classId: true },
    });

    let totalOwed = 0;
    if (student?.classId) {
      const feeStructure = await this.prisma.feeStructure.findFirst({
        where: {
          classId: student.classId,
          schoolId,
          term: term as never,
          academicYear,
        },
      });
      if (feeStructure) {
        totalOwed = Number(feeStructure.amount);
      }
    }

    const totalPaid =
      Number(payments._sum.amount ?? 0) +
      Number(bursaries._sum.discountAmount ?? 0);
    const balance = Math.max(0, totalOwed - totalPaid);

    await this.prisma.studentFeeLedger.upsert({
      where: {
        studentId_term_academicYear: {
          studentId,
          term: term as never,
          academicYear,
        },
      },
      update: {
        totalOwed,
        totalPaid,
        balance,
        lastUpdated: new Date(),
      },
      create: {
        studentId,
        schoolId,
        term: term as never,
        academicYear,
        totalOwed,
        totalPaid,
        balance,
      },
    });

    this.logger.log(
      `Ledger synced — student ${studentId} ${term}/${academicYear}: owed=${totalOwed} paid=${totalPaid} balance=${balance}`,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // BURSARY APPROVALS
  // ═══════════════════════════════════════════════════════════

  async createBursaryApproval(
    schoolId: string,
    approvedBy: string,
    dto: CreateBursaryApprovalDto,
  ) {
    const student = await this.prisma.student.findFirst({
      where: { id: dto.studentId, schoolId },
      select: { id: true, fullName: true },
    });
    if (!student) throw new NotFoundException('Student not found.');

    const approval = await this.prisma.bursaryApproval.create({
      data: {
        studentId: dto.studentId,
        schoolId,
        discountAmount: dto.discountAmount,
        reason: dto.reason,
        approvedBy,
        term: dto.term ?? null,
        academicYear: dto.academicYear ?? null,
      },
      include: {
        student: {
          select: { id: true, fullName: true, admissionNumber: true },
        },
        approver: { select: { id: true } },
      },
    });

    // Sync ledger if term+year provided
    if (dto.term && dto.academicYear) {
      await this.syncLedger(
        dto.studentId,
        schoolId,
        dto.term,
        dto.academicYear,
      );
    }

    this.logger.log(
      `Bursary approved: ₦${dto.discountAmount} for ${student.fullName}`,
    );
    return approval;
  }

  async findAllBursaryApprovals(schoolId: string, query: BursaryQueryDto) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { schoolId };
    if (query.studentId) where.studentId = query.studentId;
    if (query.term) where.term = query.term;
    if (query.academicYear) where.academicYear = query.academicYear;

    const [data, total] = await Promise.all([
      this.prisma.bursaryApproval.findMany({
        where,
        skip,
        take: limit,
        orderBy: { approvedAt: 'desc' },
        include: {
          student: {
            select: { id: true, fullName: true, admissionNumber: true },
          },
          approver: { select: { id: true } },
        },
      }),
      this.prisma.bursaryApproval.count({ where }),
    ]);

    return {
      data: data.map((b) => ({
        ...b,
        discountAmount: Number(b.discountAmount),
      })),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ═══════════════════════════════════════════════════════════
  // EXPENSES
  // ═══════════════════════════════════════════════════════════

  async createExpense(
    schoolId: string,
    recordedBy: string,
    dto: CreateExpenseDto,
  ) {
    const expense = await this.prisma.expenseRecord.create({
      data: {
        schoolId,
        description: dto.description!,
        amount: dto.amount!,
        category: dto.category!,
        recordedBy,
        date: new Date(dto.date!),
      },
      include: {
        recorder: { select: { id: true } },
      },
    });

    this.logger.log(
      `Expense recorded: ${dto.category} — ₦${dto.amount} by ${recordedBy}`,
    );
    return { ...expense, amount: Number(expense.amount) };
  }

  async findAllExpenses(schoolId: string, query: ExpenseQueryDto) {
    const page = Math.max(1, query.page ?? 1);
    const limit = Math.min(100, Math.max(1, query.limit ?? 20));
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = { schoolId };
    if (query.category) where.category = query.category;
    if (query.from || query.to) {
      where.date = {
        ...(query.from && { gte: new Date(query.from) }),
        ...(query.to && { lte: new Date(query.to) }),
      };
    }

    const [data, total] = await Promise.all([
      this.prisma.expenseRecord.findMany({
        where,
        skip,
        take: limit,
        orderBy: { date: 'desc' },
        include: {
          recorder: { select: { id: true } },
        },
      }),
      this.prisma.expenseRecord.count({ where }),
    ]);

    // Totals for the filtered range
    const totals = await this.prisma.expenseRecord.aggregate({
      where,
      _sum: { amount: true },
    });

    return {
      data: data.map((e) => ({ ...e, amount: Number(e.amount) })),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        totalAmount: Number(totals._sum.amount ?? 0),
      },
    };
  }

  // ═══════════════════════════════════════════════════════════
  // FINANCE SUMMARY (bursar/admin)
  // ═══════════════════════════════════════════════════════════

  async getFinanceSummary(
    schoolId: string,
    academicYear?: string,
    term?: string,
  ) {
    const paymentWhere: Record<string, unknown> = {
      schoolId,
      status: 'success',
    };
    const ledgerWhere: Record<string, unknown> = { schoolId };
    const expenseWhere: Record<string, unknown> = { schoolId };

    if (term) {
      paymentWhere.term = term;
      ledgerWhere.term = term;
    }
    if (academicYear) {
      paymentWhere.academicYear = academicYear;
      ledgerWhere.academicYear = academicYear;
    }

    const [
      paymentsAgg,
      ledgerAgg,
      expensesAgg,
      recentPayments,
      expenseByCategory,
      debtorCount,
    ] = await Promise.all([
      // Total collected
      this.prisma.payment.aggregate({
        where: paymentWhere,
        _sum: { amount: true },
        _count: true,
      }),
      // Total owed vs paid across all ledgers
      this.prisma.studentFeeLedger.aggregate({
        where: ledgerWhere,
        _sum: { totalOwed: true, totalPaid: true, balance: true },
      }),
      // Total expenses
      this.prisma.expenseRecord.aggregate({
        where: expenseWhere,
        _sum: { amount: true },
      }),
      // 5 most recent successful payments
      this.prisma.payment.findMany({
        where: paymentWhere,
        orderBy: { paidAt: 'desc' },
        take: 5,
        include: {
          student: {
            select: { id: true, fullName: true, admissionNumber: true },
          },
        },
      }),
      // Expenses broken down by category
      this.prisma.expenseRecord.groupBy({
        by: ['category'],
        where: expenseWhere,
        _sum: { amount: true },
        orderBy: { _sum: { amount: 'desc' } },
      }),
      // Students with outstanding balance
      this.prisma.studentFeeLedger.count({
        where: { ...ledgerWhere, balance: { gt: 0 } },
      }),
    ]);

    const totalCollected = Number(paymentsAgg._sum.amount ?? 0);
    const totalExpenses = Number(expensesAgg._sum.amount ?? 0);
    const netRevenue = totalCollected - totalExpenses;

    return {
      overview: {
        totalOwed: Number(ledgerAgg._sum.totalOwed ?? 0),
        totalCollected,
        totalOutstanding: Number(ledgerAgg._sum.balance ?? 0),
        totalExpenses,
        netRevenue,
        paymentCount: paymentsAgg._count,
        debtorCount,
        collectionRate:
          Number(ledgerAgg._sum.totalOwed ?? 0) > 0
            ? Math.round(
                (totalCollected / Number(ledgerAgg._sum.totalOwed)) * 100 * 100,
              ) / 100
            : 0,
      },
      recentPayments: recentPayments.map((p) => ({
        id: p.id,
        student: p.student,
        amount: Number(p.amount),
        term: p.term,
        academicYear: p.academicYear,
        paidAt: p.paidAt,
      })),
      expenseBreakdown: expenseByCategory.map((e) => ({
        category: e.category,
        total: Number(e._sum.amount ?? 0),
      })),
    };
  }
}
