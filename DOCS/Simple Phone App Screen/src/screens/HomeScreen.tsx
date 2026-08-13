import React, { useState, useEffect, useRef } from "react";
import { Settings, Moon, Sun, Plus, TrendingUp, TrendingDown } from "lucide-react";
import { useAppState, useAppDispatch, formatAmount } from "../store/AppContext";
import { AppCard, AppEmptyState, SkeletonCard, TransactionItem } from "../components";

interface HomeScreenProps {
  onNavigate: (screen: string, params?: Record<string, unknown>) => void;
}

function useCountUp(target: number, duration = 800) {
  const [value, setValue] = useState(0);
  useEffect(() => {
    setValue(0);
    const start = Date.now();
    const tick = () => {
      const p = Math.min((Date.now() - start) / duration, 1);
      const eased = 1 - Math.pow(1 - p, 3);
      setValue(Math.round(target * eased));
      if (p < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }, [target, duration]);
  return value;
}

export default function HomeScreen({ onNavigate }: HomeScreenProps) {
  const state = useAppState();
  const dispatch = useAppDispatch();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setLoading(false), 1000);
    return () => clearTimeout(t);
  }, []);

  const totalIncome = state.transactions.filter(t => t.type === "income").reduce((s, t) => s + t.amount, 0);
  const totalExpense = state.transactions.filter(t => t.type === "expense").reduce((s, t) => s + t.amount, 0);
  const balance = totalIncome - totalExpense;
  const recent = [...state.transactions].sort((a, b) => b.date.localeCompare(a.date)).slice(0, 5);

  const balanceDisplay = useCountUp(loading ? 0 : balance);
  const incomeDisplay = useCountUp(loading ? 0 : totalIncome, 900);
  const expenseDisplay = useCountUp(loading ? 0 : totalExpense, 900);

  const isEmpty = state.transactions.length === 0;

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <header className="flex items-center px-4 py-4 bg-card border-b border-border">
        <div className="flex-1">
          <p className="text-xs text-muted-foreground">أهلاً بك في</p>
          <h1 className="text-xl font-medium text-foreground">وِفرة</h1>
        </div>
        <button
          onClick={() => dispatch({ type: "TOGGLE_DARK" })}
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-muted transition-colors ml-2"
        >
          {state.darkMode ? <Sun size={20} className="text-foreground" /> : <Moon size={20} className="text-foreground" />}
        </button>
        <button
          onClick={() => onNavigate("settings")}
          className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-muted transition-colors"
        >
          <Settings size={20} className="text-foreground" />
        </button>
      </header>

      <div className="flex-1 overflow-y-auto px-4 py-4 gap-4 flex flex-col">
        {loading ? (
          <>
            <SkeletonCard lines={3} />
            <div className="grid grid-cols-2 gap-3">
              <SkeletonCard lines={2} />
              <SkeletonCard lines={2} />
            </div>
            <SkeletonCard lines={2} />
            <SkeletonCard lines={2} />
          </>
        ) : isEmpty ? (
          <div className="flex-1 flex items-center justify-center">
            <AppEmptyState
              icon={<span className="text-5xl">💳</span>}
              title="مرحباً بك في وِفرة!"
              subtitle="ابدأ بتسجيل أول معاملة مالية لتتبع مصاريفك ودخلك"
              action={{ label: "أضف أول معاملة", onClick: () => onNavigate("addExpense") }}
            />
          </div>
        ) : (
          <>
            {/* Balance card */}
            <AppCard className="bg-primary text-primary-foreground border-0">
              <p className="text-sm opacity-80 mb-1">الرصيد الكلي</p>
              <p className="text-[32px] font-medium" style={{ direction: "ltr", textAlign: "right" }}>
                {balanceDisplay.toLocaleString("ar-SY")} <span className="text-lg font-normal opacity-80">{state.currency}</span>
              </p>
              <p className="text-xs opacity-60 mt-1">جميع المعاملات</p>
            </AppCard>

            {/* Income / Expense row */}
            <div className="grid grid-cols-2 gap-3">
              <AppCard className="border-l-4" style={{ borderLeftColor: "var(--primary)" }}>
                <div className="flex items-center gap-2 mb-1">
                  <TrendingUp size={16} className="text-primary" />
                  <p className="text-xs text-muted-foreground">إجمالي الدخل</p>
                </div>
                <p className="text-lg font-medium text-primary" style={{ direction: "ltr", textAlign: "right" }}>
                  {incomeDisplay.toLocaleString("ar-SY")}
                </p>
                <p className="text-xs text-muted-foreground">{state.currency}</p>
              </AppCard>
              <AppCard className="border-l-4" style={{ borderLeftColor: "var(--secondary)" }}>
                <div className="flex items-center gap-2 mb-1">
                  <TrendingDown size={16} className="text-secondary" />
                  <p className="text-xs text-muted-foreground">إجمالي المصاريف</p>
                </div>
                <p className="text-lg font-medium text-secondary" style={{ direction: "ltr", textAlign: "right" }}>
                  {expenseDisplay.toLocaleString("ar-SY")}
                </p>
                <p className="text-xs text-muted-foreground">{state.currency}</p>
              </AppCard>
            </div>

            {/* Recent transactions */}
            <div>
              <div className="flex items-center justify-between mb-3">
                <h2 className="text-base font-medium text-foreground">آخر المعاملات</h2>
                <button onClick={() => onNavigate("transactions")} className="text-sm text-primary font-medium">
                  عرض الكل
                </button>
              </div>
              <AppCard className="p-0 px-4">
                {recent.map((tx, i) => (
                  <div key={tx.id} style={{ animation: `slide-up 0.3s ease-out ${i * 0.08}s both` }}>
                    <TransactionItem tx={tx} onClick={() => onNavigate("transactionDetail", { id: tx.id })} />
                  </div>
                ))}
              </AppCard>
            </div>
          </>
        )}
      </div>

      {/* FAB */}
      {!loading && <SpeedDial onAddIncome={() => onNavigate("addIncome")} onAddExpense={() => onNavigate("addExpense")} />}
    </div>
  );
}

// ─── SpeedDial FAB ─────────────────────────────────────────
function SpeedDial({ onAddIncome, onAddExpense }: { onAddIncome: () => void; onAddExpense: () => void }) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  // Close on outside click
  useEffect(() => {
    if (!open) return;
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, [open]);

  return (
    <div ref={ref} className="absolute bottom-20 left-4 flex flex-col items-start gap-3">
      {/* Sub-button: دخل */}
      <div
        style={{
          transition: "opacity 0.28s ease, transform 0.28s cubic-bezier(0.34,1.56,0.64,1)",
          opacity: open ? 1 : 0,
          transform: open ? "translateY(0) scale(1)" : "translateY(20px) scale(0.85)",
          pointerEvents: open ? "auto" : "none",
          transitionDelay: open ? "0.08s" : "0s",
        }}
      >
        <button
          onClick={() => { setOpen(false); onAddIncome(); }}
          className="flex items-center gap-2 pl-4 pr-5 py-2.5 rounded-full shadow-lg text-sm font-medium active:scale-95 transition-transform"
          style={{ background: "var(--primary)", color: "var(--primary-foreground)" }}
        >
          <TrendingUp size={15} />
          <span>دخل</span>
        </button>
      </div>

      {/* Sub-button: مصروف */}
      <div
        style={{
          transition: "opacity 0.22s ease, transform 0.22s cubic-bezier(0.34,1.56,0.64,1)",
          opacity: open ? 1 : 0,
          transform: open ? "translateY(0) scale(1)" : "translateY(14px) scale(0.85)",
          pointerEvents: open ? "auto" : "none",
          transitionDelay: open ? "0s" : "0s",
        }}
      >
        <button
          onClick={() => { setOpen(false); onAddExpense(); }}
          className="flex items-center gap-2 pl-4 pr-5 py-2.5 rounded-full shadow-lg text-sm font-medium active:scale-95 transition-transform"
          style={{ background: "var(--secondary)", color: "var(--secondary-foreground)" }}
        >
          <TrendingDown size={15} />
          <span>مصروف</span>
        </button>
      </div>

      {/* Main FAB */}
      <button
        onClick={() => setOpen(o => !o)}
        className="w-14 h-14 rounded-full flex items-center justify-center shadow-xl active:scale-90 transition-transform"
        style={{
          background: open ? "var(--foreground)" : "var(--primary)",
          transition: "background 0.25s ease, transform 0.1s ease",
        }}
      >
        <Plus
          size={26}
          style={{
            color: open ? "var(--background)" : "var(--primary-foreground)",
            transition: "transform 0.35s cubic-bezier(0.34,1.56,0.64,1), color 0.25s ease",
            transform: open ? "rotate(45deg)" : "rotate(0deg)",
          }}
        />
      </button>
    </div>
  );
}
