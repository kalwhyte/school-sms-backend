import { StudentsHelperService } from './index.service';

// ─── shared fixtures ──────────────────────────────────────────────────────────

const mockPrisma = {
  student: {
    count: jest.fn(),
  },
};

const baseStudent = {
  id: 'student-001',
  admissionNumber: 'GFA010/2026/0001',
  fullName: 'Emmanuel Tony',
  dob: new Date('2007-07-14'),
  gender: 'male',
  classId: 'class-001',
  guardianName: 'Mrs. Ngozi Okafor',
  photoUrl: 'https://res.cloudinary.com/demo/photo.png',
  isActive: true,
  schoolId: 'school-001',
  userId: 'user-001',
  createdAt: new Date('2026-01-01'),
  updatedAt: new Date('2026-01-01'),
  currentClass: { id: 'class-001', name: 'JSS 2' },
};

const baseUser = {
  phone: '+2348044345678',
  email: 'emeka@gmail.com',
};

// ─── tests ────────────────────────────────────────────────────────────────────

describe('StudentsHelperService', () => {
  let service: StudentsHelperService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new StudentsHelperService(mockPrisma as any);
  });

  // ─── generateAdmissionNumber ───────────────────────────────────────────────

  describe('generateAdmissionNumber', () => {
    const year = new Date().getFullYear();

    it('should return correctly formatted admission number', async () => {
      mockPrisma.student.count.mockResolvedValueOnce(0);

      const result = await service.generateAdmissionNumber('school-001', 'GFA010');

      expect(result).toBe(`GFA010/${year}/0001`);
    });

    it('should increment sequence based on existing student count', async () => {
      mockPrisma.student.count.mockResolvedValueOnce(4);

      const result = await service.generateAdmissionNumber('school-001', 'GFA010');

      expect(result).toBe(`GFA010/${year}/0005`);
    });

    it('should zero-pad the sequence to 4 digits', async () => {
      mockPrisma.student.count.mockResolvedValueOnce(9);

      const result = await service.generateAdmissionNumber('school-001', 'GFA010');

      expect(result).toBe(`GFA010/${year}/0010`);
    });

    it('should query with the correct prefix filter', async () => {
      mockPrisma.student.count.mockResolvedValueOnce(0);

      await service.generateAdmissionNumber('school-001', 'GFA010');

      expect(mockPrisma.student.count).toHaveBeenCalledWith({
        where: {
          schoolId: 'school-001',
          admissionNumber: { startsWith: `GFA010/${year}/` },
        },
      });
    });

    it('should handle large counts without losing padding', async () => {
      mockPrisma.student.count.mockResolvedValueOnce(999);

      const result = await service.generateAdmissionNumber('school-001', 'GFA010');

      expect(result).toBe(`GFA010/${year}/1000`);
    });
  });

  // ─── formatStudent ─────────────────────────────────────────────────────────

  describe('formatStudent', () => {
    it('should map all fields correctly from student + user', () => {
      const result = service.formatStudent(baseStudent, baseUser);

      expect(result).toEqual({
        id: 'student-001',
        admissionNumber: 'GFA010/2026/0001',
        fullName: 'Emmanuel Tony',
        dateOfBirth: '2007-07-14',
        gender: 'male',
        guardianName: 'Mrs. Ngozi Okafor',
        phone: '+2348044345678',
        email: 'emeka@gmail.com',
        photoUrl: 'https://res.cloudinary.com/demo/photo.png',
        isActive: true,
        classId: 'class-001',
        currentClass: { id: 'class-001', name: 'JSS 2' },
        schoolId: 'school-001',
        userId: 'user-001',
        createdAt: baseStudent.createdAt,
        updatedAt: baseStudent.updatedAt,
      });
    });

    it('should format dob as YYYY-MM-DD date string', () => {
      const result = service.formatStudent(baseStudent, baseUser);
      expect(result.dateOfBirth).toBe('2007-07-14');
    });

    it('should return null for dateOfBirth when dob is null', () => {
      const result = service.formatStudent({ ...baseStudent, dob: null }, baseUser);
      expect(result.dateOfBirth).toBeNull();
    });

    it('should return null phone and email when user is null', () => {
      const result = service.formatStudent(baseStudent, null);
      expect(result.phone).toBeNull();
      expect(result.email).toBeNull();
    });

    it('should return null phone and email when user fields are null', () => {
      const result = service.formatStudent(baseStudent, { phone: null, email: null });
      expect(result.phone).toBeNull();
      expect(result.email).toBeNull();
    });

    it('should return null for currentClass when not provided', () => {
      const { currentClass, ...studentWithoutClass } = baseStudent;
      const result = service.formatStudent(studentWithoutClass as any, baseUser);
      expect(result.currentClass).toBeNull();
    });

    it('should handle null optional student fields', () => {
      const result = service.formatStudent(
        {
          ...baseStudent,
          gender: null,
          guardianName: null,
          photoUrl: null,
          classId: null,
          userId: null,
        },
        baseUser,
      );

      expect(result.gender).toBeNull();
      expect(result.guardianName).toBeNull();
      expect(result.photoUrl).toBeNull();
      expect(result.classId).toBeNull();
      expect(result.userId).toBeNull();
    });
  });
});
