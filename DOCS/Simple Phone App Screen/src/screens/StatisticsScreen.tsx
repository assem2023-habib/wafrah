import React, { useMemo, useState } from "react";
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Legend, Rectangle } from "recharts";
import { useAppState } from "../store/AppContext";
import { PageHeader, AppEmptyState } from "../components";

// ─── Custom cursor: fade-in background on hover ────────────
function MonthHoverCursor({ x = 0, y = 0, width = 0, height = 0 }: { x?: number; y?: number; width?: number; height?: number }) {
  return (
    <rect
      x={x - 6}
      y={y}
      width={width + 12}
      height={height}
      rx={8}
      fill="var(--primary)"
      fillOpacity={0.08}
      style={{ transition: "fill-opacity 0.2s ease" }}
    />
  );
}

// ─── Monthly row with hover fade animation ─────────────────
function MonthRow({ row, fmtAmount }: { row: { name: string; دخل: number; مصاريف: number }; fmtAmount: (v: number) => string }) {
  const [hovered, setHovered] = useState(false);
  return (
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        display: "flex",
        alignItems: "center",
        gap: 12,
        padding: "8px 10px",
        borderRadius: 10,
        background: hovered ? "var(--muted)" : "transparent",
        transition: "background 0.25s ease",
        cursor: "default",
      }}
    >
      <span style={{ fontSize: 12, fontWeight: 500, color: "var(--muted-foreground)", width: 32, textAlign: "center" }}>{row.name}</span>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 2 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{ width: 8, height: 8, borderRadius: "50%", background: "#6B8E6B", flexShrink: 0 }} />
          <span style={{ fontSize: 11, color: "var(--muted-foreground)", flex: 1 }}>دخل</span>
          <span style={{ fontSize: 11, fontWeight: 500, color: "var(--primary)", direction: "ltr" }}>{fmtAmount(row["دخل"])}</span>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{ width: 8, height: 8, borderRadius: "50%", background: "#C97B4A", flexShrink: 0 }} />
          <span style={{ fontSize: 11, color: "var(--muted-foreground)", flex: 1 }}>مصاريف</span>
          <span style={{ fontSize: 11, fontWeight: 500, color: "var(--secondary)", direction: "ltr" }}>{fmtAmount(row["مصاريف"])}</span>
        </div>
      </div>
    </div>
  );
}

const PERIOD_OPTIONS = [
  { value: 1, label: "هذا الشهر" },
  { value: 3, label: "3 أشهر" },
  { value: 6, label: "6 أشهر" },
  { value: 12, label: "سنة" },
];

const CHART_COLORS = ["#6B8E6B", "#C97B4A", "#8AAFB8", "#A07850", "#9BAF8A", "#D4A070", "#7A9B8A", "#C4956A"];

export default function StatisticsScreen({ onBack }: { onBack: () => void }) {
  const state = useAppState();
  const [period, setPeriod] = useState(1);

  const cutoff = useMemo(() => {
    const d = new Date();
    d.setMonth(d.getMonth() - period);
    return d.toISOString().split("T")[0];
  }, [period]);

  const inPeriod = useMemo(() =>
    state.transactions.filter(t => t.date >= cutoff),
    [state.transactions, cutoff]
  );

  const expenseByCategory = useMemo(() => {
    const map: Record<string, number> = {};
    inPeriod.filter(t => t.type === "expense").forEach(t => {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    });
    return Object.entries(map).map(([catId, value]) => {
      const cat = state.categories.find(c => c.id === catId);
      return { name: cat?.name ?? catId, value, icon: cat?.icon ?? "" };
    }).sort((a, b) => b.value - a.value);
  }, [inPeriod, state.categories]);

  const monthlyData = useMemo(() => {
    const map: Record<string, { income: number; expense: number }> = {};
    inPeriod.forEach(t => {
      const month = t.date.slice(0, 7);
      if (!map[month]) map[month] = { income: 0, expense: 0 };
      map[month][t.type] += t.amount;
    });
    return Object.entries(map)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([month, data]) => {
        const d = new Date(month + "-01");
        return {
          name: d.toLocaleDateString("ar-SY", { month: "short" }),
          دخل: data.income,
          مصاريف: data.expense,
        };
      });
  }, [inPeriod]);

  const totalIncome = inPeriod.filter(t => t.type === "income").reduce((s, t) => s + t.amount, 0);
  const totalExpense = inPeriod.filter(t => t.type === "expense").reduce((s, t) => s + t.amount, 0);

  const fmtAmount = (v: number) => v.toLocaleString("ar-SY") + " " + state.currency;

  return (
    <div className="flex flex-col h-full">
      <PageHeader title="الإحصائيات" onBack={onBack} />

      {/* Period tabs */}
      <div className="flex px-4 pt-3 gap-2 overflow-x-auto border-b border-border pb-3 bg-card">
        {PERIOD_OPTIONS.map(opt => (
          <button
            key={opt.value}
            onClick={() => setPeriod(opt.value)}
            className={`shrink-0 px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${period === opt.value ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"}`}
          >
            {opt.label}
          </button>
        ))}
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-4 flex flex-col gap-5">
        {inPeriod.length === 0 ? (
          <AppEmptyState
            icon={<span className="text-5xl">📊</span>}
            title="لا توجد بيانات"
            subtitle="أضف معاملات لرؤية الإحصائيات"
          />
        ) : (
          <>
            {/* Summary row */}
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-primary/10 rounded-xl p-4">
                <p className="text-xs text-muted-foreground mb-1">إجمالي الدخل</p>
                <p className="text-base font-medium text-primary" style={{ direction: "ltr", textAlign: "right" }}>{fmtAmount(totalIncome)}</p>
              </div>
              <div className="bg-secondary/10 rounded-xl p-4">
                <p className="text-xs text-muted-foreground mb-1">إجمالي المصاريف</p>
                <p className="text-base font-medium text-secondary" style={{ direction: "ltr", textAlign: "right" }}>{fmtAmount(totalExpense)}</p>
              </div>
            </div>

            {/* Pie chart */}
            {expenseByCategory.length > 0 && (
              <div className="bg-card border border-border rounded-xl p-4">
                <h2 className="text-base font-medium text-foreground mb-4">توزيع المصاريف</h2>
                <ResponsiveContainer width="100%" height={200}>
                  <PieChart>
                    <Pie
                      data={expenseByCategory}
                      cx="50%"
                      cy="50%"
                      innerRadius={55}
                      outerRadius={85}
                      paddingAngle={3}
                      dataKey="value"
                      isAnimationActive
                      animationDuration={800}
                    >
                      {expenseByCategory.map((_, i) => (
                        <Cell key={i} fill={CHART_COLORS[i % CHART_COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip
                      formatter={(v: number) => [fmtAmount(v), ""]}
                      contentStyle={{ background: "var(--card)", border: "1px solid var(--border)", borderRadius: 12, fontFamily: "Cairo" }}
                    />
                  </PieChart>
                </ResponsiveContainer>
                {/* Legend */}
                <div className="flex flex-col gap-2 mt-2">
                  {expenseByCategory.slice(0, 5).map((item, i) => (
                    <div key={i} className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded-full shrink-0" style={{ background: CHART_COLORS[i % CHART_COLORS.length] }} />
                      <span className="text-xs text-muted-foreground flex-1">{item.icon} {item.name}</span>
                      <span className="text-xs font-medium text-foreground" style={{ direction: "ltr" }}>{fmtAmount(item.value)}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Bar chart */}
            {monthlyData.length > 0 && (
              <div className="bg-card border border-border rounded-xl p-4">
                <h2 className="text-base font-medium text-foreground mb-4">الدخل والمصاريف شهرياً</h2>
                <ResponsiveContainer width="100%" height={200}>
                  <BarChart
                    data={monthlyData}
                    margin={{ top: 0, right: 0, bottom: 0, left: -20 }}
                  >
                    <XAxis dataKey="name" tick={{ fontSize: 11, fontFamily: "Cairo", fill: "var(--muted-foreground)" }} />
                    <YAxis tick={{ fontSize: 10, fontFamily: "Cairo", fill: "var(--muted-foreground)" }} tickFormatter={v => (v / 1000) + "k"} />
                    <Tooltip
                      formatter={(v: number, name: string) => [fmtAmount(v), name]}
                      contentStyle={{ background: "var(--card)", border: "1px solid var(--border)", borderRadius: 12, fontFamily: "Cairo" }}
                      cursor={<MonthHoverCursor />}
                    />
                    <Bar dataKey="دخل" fill="#6B8E6B" radius={[4, 4, 0, 0]} isAnimationActive animationDuration={800} activeBar={<Rectangle fill="#8FB08F" radius={[4, 4, 0, 0]} />} />
                    <Bar dataKey="مصاريف" fill="#C97B4A" radius={[4, 4, 0, 0]} isAnimationActive animationDuration={900} activeBar={<Rectangle fill="#D99568" radius={[4, 4, 0, 0]} />} />
                    <Legend wrapperStyle={{ fontFamily: "Cairo", fontSize: 12 }} />
                  </BarChart>
                </ResponsiveContainer>

                {/* Monthly rows with hover animation */}
                <div className="mt-4 flex flex-col gap-1">
                  {monthlyData.map((row, i) => (
                    <MonthRow key={i} row={row} fmtAmount={fmtAmount} />
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
