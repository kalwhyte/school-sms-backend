import { AuthHelperService } from '../../../src/modules/auth/services/auth-helper.service';

describe('AuthHelperService', () => {
  let service: AuthHelperService;

  beforeEach(() => {
    service = new AuthHelperService();
  });

  // ─── generateOtp ──────────────────────────────────────────────────────────

  describe('generateOtp', () => {
    it('should return a 6-character string', () => {
      expect(service.generateOtp()).toHaveLength(6);
    });

    it('should only contain digits', () => {
      expect(service.generateOtp()).toMatch(/^\d{6}$/);
    });

    it('should zero-pad values below 100000', () => {
      // Run enough times to statistically hit a leading-zero case
      const otps = Array.from({ length: 200 }, () => service.generateOtp());
      otps.forEach((otp) => expect(otp).toHaveLength(6));
    });

    it('should produce different values across calls (not static)', () => {
      const set = new Set(
        Array.from({ length: 20 }, () => service.generateOtp()),
      );
      // Probability of all 20 being equal by chance is astronomically small
      expect(set.size).toBeGreaterThan(1);
    });
  });

  // ─── hashValue ────────────────────────────────────────────────────────────

  describe('hashValue', () => {
    it('should return a 64-character hex string (SHA-256)', () => {
      expect(service.hashValue('test')).toMatch(/^[a-f0-9]{64}$/);
    });

    it('should be deterministic — same input produces same hash', () => {
      expect(service.hashValue('hello')).toBe(service.hashValue('hello'));
    });

    it('should produce different hashes for different inputs', () => {
      expect(service.hashValue('abc')).not.toBe(service.hashValue('xyz'));
    });

    it('should match a known SHA-256 hash', () => {
      // echo -n "Password@123" | sha256sum
      const known =
        '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8';
      // This verifies the algorithm is actually SHA-256, not MD5 / SHA-1
      expect(service.hashValue('password')).toBe(known);
    });
  });

  // ─── generateRandomToken ──────────────────────────────────────────────────

  describe('generateRandomToken', () => {
    it('should return a 128-character hex string (64 random bytes)', () => {
      expect(service.generateRandomToken()).toMatch(/^[a-f0-9]{128}$/);
    });

    it('should produce unique tokens on each call', () => {
      const a = service.generateRandomToken();
      const b = service.generateRandomToken();
      expect(a).not.toBe(b);
    });
  });
});
