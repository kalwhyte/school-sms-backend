export interface SchoolRow {
  id: string;
  name: string;
  address: string;
  logoUrl: string | null;
  schoolCode: string;
  subscriptionTier: string;
  currency: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface SchoolWithStatsRow extends SchoolRow {
  _count: {
    students: number;
    staff: number;
    users: number;
  };
}
