import React, { useState, useMemo } from "react";
import { Search, Filter, X } from "lucide-react";
import { useAppState } from "../store/AppContext";
import { PageHeader, AppEmptyState, TransactionItem, AppDropdownField } from "../components";

interface Props {
  onNavigate: (screen: string, params?: Record<string, unknown>) => void;
  onBack: () => void;
}

export default function TransactionsScreen({ onNavigate, onBack }: Props) {
  const state = useAppState();
  const [search, setSearch] = useState("");
  const [filterType, setFilterType] = useState("");
  const [filterCat, setFilterCat] = useState("");
  const [showFilter, setShowFilter] = useState(false);

  const sorted = useMemo(() =>
    [...state.transactions].sort((a, b) => b.date.localeCompare(a.date)),
    [state.transactions]
  );

  const filtered = useMemo(() => {
    return sorted.filter(tx => {
      const cat = state.categories.find(c => c.id === tx.categoryId);
      const matchSearch = !search || cat?.name.includes(search) || tx.note?.includes(search);
      const matchType = !filterType || tx.type === filterType;
      const matchCat = !filterCat || tx.categoryId === filterCat;
      return matchSearch && matchType && matchCat;
    });
  }, [sorted, search, filterType, filterCat, state.categories]);

  // Group by date
  const grouped = useMemo(() => {
    const map: Record<string, typeof filtered> = {};
    filtered.forEach(tx => {
      if (!map[tx.date]) map[tx.date] = [];
      map[tx.date].push(tx);
    });
    return Object.entries(map).sort(([a], [b]) => b.localeCompare(a));
  }, [filtered]);

  const hasActiveFilter = filterType || filterCat;
  const catOptions = state.categories.map(c => ({ value: c.id, label: c.name, icon: c.icon }));

  return (
    <div className="flex flex-col h-full">
      <PageHeader title="سجل المعاملات" onBack={onBack} />

      {/* Search */}
      <div className="px-4 py-3 bg-card border-b border-border flex items-center gap-2">
        <div className="flex-1 flex items-center gap-2 h-10 px-3 rounded-xl bg-input-background border border-border">
          <Search size={16} className="text-muted-foreground shrink-0" />
          <input
            value={search}
            onChange={e => setSearch(e.target.value)}
            placeholder="بحث..."
            className="flex-1 bg-transparent text-sm text-foreground focus:outline-none placeholder:text-muted-foreground"
          />
          {search && <button onClick={() => setSearch("")}><X size={14} className="text-muted-foreground" /></button>}
        </div>
        <button
          onClick={() => setShowFilter(f => !f)}
          className={`w-10 h-10 flex items-center justify-center rounded-xl border transition-colors ${hasActiveFilter ? "bg-primary text-primary-foreground border-primary" : "border-border text-muted-foreground hover:bg-muted"}`}
        >
          <Filter size={16} />
        </button>
      </div>

      {/* Filters panel */}
      {showFilter && (
        <div className="px-4 py-3 bg-muted/50 border-b border-border flex flex-col gap-2">
          <div className="grid grid-cols-2 gap-2">
            <select
              value={filterType}
              onChange={e => setFilterType(e.target.value)}
              className="h-10 px-3 rounded-xl border border-border bg-input-background text-sm text-foreground focus:outline-none focus:border-primary"
            >
              <option value="">كل الأنواع</option>
              <option value="income">دخل</option>
              <option value="expense">مصروف</option>
            </select>
            <select
              value={filterCat}
              onChange={e => setFilterCat(e.target.value)}
              className="h-10 px-3 rounded-xl border border-border bg-input-background text-sm text-foreground focus:outline-none focus:border-primary"
            >
              <option value="">كل التصنيفات</option>
              {catOptions.map(o => <option key={o.value} value={o.value}>{o.icon} {o.label}</option>)}
            </select>
          </div>
          {hasActiveFilter && (
            <button onClick={() => { setFilterType(""); setFilterCat(""); }} className="text-xs text-destructive font-medium text-right">
              مسح الفلاتر
            </button>
          )}
        </div>
      )}

      <div className="flex-1 overflow-y-auto px-4 py-3">
        {state.transactions.length === 0 ? (
          <AppEmptyState
            icon={<span className="text-5xl">📋</span>}
            title="لا توجد معاملات بعد"
            subtitle="أضف أول معاملة من الشاشة الرئيسية"
          />
        ) : filtered.length === 0 ? (
          <AppEmptyState
            icon={<span className="text-5xl">🔍</span>}
            title="لا توجد نتائج"
            subtitle="جرّب تغيير معايير البحث أو الفلتر"
            action={{ label: "مسح الفلاتر", onClick: () => { setSearch(""); setFilterType(""); setFilterCat(""); } }}
          />
        ) : (
          <div className="flex flex-col gap-4">
            {grouped.map(([date, txs]) => (
              <div key={date}>
                <p className="text-xs font-medium text-muted-foreground mb-2 pb-1 border-b border-border">
                  {new Date(date).toLocaleDateString("ar-SY", { weekday: "long", year: "numeric", month: "long", day: "numeric" })}
                </p>
                <div className="bg-card border border-border rounded-xl px-4">
                  {txs.map(tx => (
                    <TransactionItem
                      key={tx.id}
                      tx={tx}
                      onClick={() => onNavigate("transactionDetail", { id: tx.id })}
                    />
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
