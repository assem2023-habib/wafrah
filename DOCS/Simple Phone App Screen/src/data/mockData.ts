export interface Category {
  id: string;
  name: string;
  icon: string;
  type: "expense" | "income" | "both";
}

export interface Product {
  id: string;
  name: string;
  categoryId: string;
}

export interface Transaction {
  id: string;
  type: "expense" | "income";
  amount: number;
  categoryId: string;
  productId?: string;
  date: string;
  note?: string;
}

export interface ElectricityReading {
  id: string;
  value: number;
  date: string;
  consumption: number;
  cost: number;
}

export const defaultCategories: Category[] = [
  { id: "food", name: "طعام وشراب", icon: "🍽️", type: "expense" },
  { id: "transport", name: "مواصلات", icon: "🚗", type: "expense" },
  { id: "health", name: "صحة وأدوية", icon: "💊", type: "expense" },
  { id: "home", name: "منزل", icon: "🏠", type: "expense" },
  { id: "electricity", name: "كهرباء", icon: "⚡", type: "expense" },
  { id: "shopping", name: "تسوق", icon: "🛍️", type: "expense" },
  { id: "entertainment", name: "ترفيه", icon: "🎬", type: "expense" },
  { id: "other_exp", name: "أخرى", icon: "📦", type: "expense" },
  { id: "salary", name: "راتب", icon: "💼", type: "income" },
  { id: "pension", name: "تقاعد", icon: "🏦", type: "income" },
  { id: "gift", name: "هدية", icon: "🎁", type: "income" },
  { id: "other_inc", name: "دخل آخر", icon: "💰", type: "income" },
];

export const defaultProducts: Product[] = [
  { id: "p1", name: "خبز", categoryId: "food" },
  { id: "p2", name: "لحم", categoryId: "food" },
  { id: "p3", name: "خضروات", categoryId: "food" },
  { id: "p4", name: "دجاج", categoryId: "food" },
  { id: "p5", name: "أدوية مزمنة", categoryId: "health" },
  { id: "p6", name: "كشف طبي", categoryId: "health" },
];

const today = new Date();
const fmt = (d: Date) => d.toISOString().split("T")[0];
const daysAgo = (n: number) => {
  const d = new Date(today);
  d.setDate(d.getDate() - n);
  return fmt(d);
};

export const defaultTransactions: Transaction[] = [
  { id: "t1", type: "income", amount: 450000, categoryId: "salary", date: daysAgo(0), note: "راتب شهر أغسطس" },
  { id: "t2", type: "expense", amount: 25000, categoryId: "food", productId: "p1", date: daysAgo(1) },
  { id: "t3", type: "expense", amount: 85000, categoryId: "health", productId: "p5", date: daysAgo(2), note: "دواء ضغط الدم" },
  { id: "t4", type: "expense", amount: 15000, categoryId: "transport", date: daysAgo(3) },
  { id: "t5", type: "income", amount: 120000, categoryId: "pension", date: daysAgo(4), note: "معاش التقاعد" },
  { id: "t6", type: "expense", amount: 60000, categoryId: "food", productId: "p2", date: daysAgo(5) },
  { id: "t7", type: "expense", amount: 35000, categoryId: "shopping", date: daysAgo(7) },
  { id: "t8", type: "expense", amount: 12000, categoryId: "entertainment", date: daysAgo(8) },
  { id: "t9", type: "expense", amount: 45000, categoryId: "home", date: daysAgo(10), note: "فاتورة ماء" },
  { id: "t10", type: "income", amount: 50000, categoryId: "gift", date: daysAgo(12), note: "هدية من الأبناء" },
  { id: "t11", type: "expense", amount: 22000, categoryId: "food", productId: "p3", date: daysAgo(14) },
  { id: "t12", type: "expense", amount: 18000, categoryId: "transport", date: daysAgo(16) },
  { id: "t13", type: "expense", amount: 95000, categoryId: "health", productId: "p6", date: daysAgo(20) },
  { id: "t14", type: "income", amount: 450000, categoryId: "salary", date: daysAgo(30), note: "راتب شهر يوليو" },
  { id: "t15", type: "expense", amount: 75000, categoryId: "electricity", date: daysAgo(25), note: "فاتورة كهرباء" },
];

export const defaultReadings: ElectricityReading[] = [
  { id: "r1", value: 1200, date: daysAgo(60), consumption: 0, cost: 0 },
  { id: "r2", value: 1380, date: daysAgo(30), consumption: 180, cost: 54000 },
  { id: "r3", value: 1540, date: daysAgo(0), consumption: 160, cost: 48000 },
];
