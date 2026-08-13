import React, { useState, useEffect, useRef } from "react";
import { X, ChevronDown, Check, AlertCircle, PackageOpen } from "lucide-react";

// ─── AppCard ───────────────────────────────────────────────
export function AppCard({ children, className = "" }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={`bg-card border border-border rounded-xl p-4 ${className}`}>
      {children}
    </div>
  );
}

// ─── AppPrimaryButton ──────────────────────────────────────
interface BtnProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "danger";
  fullWidth?: boolean;
}
export function AppPrimaryButton({ children, variant = "primary", fullWidth = true, className = "", ...props }: BtnProps) {
  const colors = {
    primary: "bg-primary text-primary-foreground hover:opacity-90",
    secondary: "bg-secondary text-secondary-foreground hover:opacity-90",
    danger: "bg-destructive text-destructive-foreground hover:opacity-90",
  };
  return (
    <button
      className={`
        flex items-center justify-center gap-2
        h-12 rounded-xl px-6
        transition-all duration-150 active:scale-95
        font-medium text-base
        disabled:opacity-50 disabled:cursor-not-allowed
        ${colors[variant]}
        ${fullWidth ? "w-full" : ""}
        ${className}
      `}
      {...props}
    >
      {children}
    </button>
  );
}

export function AppSecondaryButton({ children, fullWidth = true, className = "", ...props }: BtnProps) {
  return (
    <button
      className={`
        flex items-center justify-center gap-2
        h-12 rounded-xl px-6 border border-primary text-primary
        bg-transparent hover:bg-primary/10
        transition-all duration-150 active:scale-95
        font-medium text-base
        disabled:opacity-50
        ${fullWidth ? "w-full" : ""}
        ${className}
      `}
      {...props}
    >
      {children}
    </button>
  );
}

// ─── AppTextField ──────────────────────────────────────────
interface TextFieldProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}
export function AppTextField({ label, error, className = "", ...props }: TextFieldProps) {
  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-medium text-foreground">{label}</label>
      <input
        className={`
          h-[52px] px-4 rounded-xl border text-base
          bg-input-background border-border
          focus:outline-none focus:border-primary
          transition-colors placeholder:text-muted-foreground
          ${error ? "border-destructive" : ""}
          ${className}
        `}
        {...props}
      />
      {error && <p className="text-xs text-destructive">{error}</p>}
    </div>
  );
}

// ─── AppNumberField ────────────────────────────────────────
interface NumberFieldProps {
  label: string;
  value: string;
  onChange: (v: string) => void;
  suffix?: string;
  error?: string;
  placeholder?: string;
}
export function AppNumberField({ label, value, onChange, suffix = "ل.س", error, placeholder = "0" }: NumberFieldProps) {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const raw = e.target.value.replace(/[^0-9]/g, "");
    onChange(raw);
  };
  const display = value ? parseInt(value).toLocaleString("ar-SY") : "";

  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-medium text-foreground">{label}</label>
      <div className={`flex items-center h-[52px] rounded-xl border bg-input-background ${error ? "border-destructive" : "border-border"} px-4 gap-2 focus-within:border-primary transition-colors`}>
        <input
          type="text"
          inputMode="numeric"
          value={display}
          onChange={handleChange}
          placeholder={placeholder}
          className="flex-1 bg-transparent text-[20px] font-medium text-foreground focus:outline-none min-w-0"
          style={{ direction: "ltr", textAlign: "right" }}
        />
        <span className="text-sm text-muted-foreground shrink-0">{suffix}</span>
      </div>
      {error && <p className="text-xs text-destructive">{error}</p>}
    </div>
  );
}

// ─── AppDateField ──────────────────────────────────────────
interface DateFieldProps {
  label: string;
  value: string;
  onChange: (v: string) => void;
  error?: string;
}
export function AppDateField({ label, value, onChange, error }: DateFieldProps) {
  const formatDisplay = (iso: string) => {
    if (!iso) return "";
    const d = new Date(iso);
    return d.toLocaleDateString("ar-SY", { year: "numeric", month: "long", day: "numeric" });
  };
  return (
    <div className="flex flex-col gap-1">
      <label className="text-sm font-medium text-foreground">{label}</label>
      <div className={`relative h-[52px] rounded-xl border bg-input-background ${error ? "border-destructive" : "border-border"} focus-within:border-primary transition-colors`}>
        <span className="absolute inset-0 flex items-center px-4 text-base pointer-events-none text-foreground">
          {formatDisplay(value) || <span className="text-muted-foreground">اختر التاريخ</span>}
        </span>
        <input
          type="date"
          value={value}
          onChange={e => onChange(e.target.value)}
          className="absolute inset-0 opacity-0 cursor-pointer w-full h-full"
        />
      </div>
      {error && <p className="text-xs text-destructive">{error}</p>}
    </div>
  );
}

// ─── AppDropdownField ──────────────────────────────────────
interface DropdownOption { value: string; label: string; icon?: string; }
interface DropdownProps {
  label: string;
  value: string;
  onChange: (v: string) => void;
  options: DropdownOption[];
  placeholder?: string;
  error?: string;
}
export function AppDropdownField({ label, value, onChange, options, placeholder = "اختر...", error }: DropdownProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const selected = options.find(o => o.value === value);

  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", handler);
    return () => document.removeEventListener("mousedown", handler);
  }, []);

  return (
    <div className="flex flex-col gap-1" ref={ref}>
      <label className="text-sm font-medium text-foreground">{label}</label>
      <div
        className={`flex items-center justify-between h-[52px] px-4 rounded-xl border bg-input-background cursor-pointer ${error ? "border-destructive" : "border-border"} ${open ? "border-primary" : ""} transition-colors`}
        onClick={() => setOpen(o => !o)}
      >
        <span className={`text-base ${selected ? "text-foreground" : "text-muted-foreground"}`}>
          {selected ? `${selected.icon ? selected.icon + " " : ""}${selected.label}` : placeholder}
        </span>
        <ChevronDown size={18} className={`text-muted-foreground transition-transform ${open ? "rotate-180" : ""}`} />
      </div>
      {open && (
        <div className="bg-card border border-border rounded-xl shadow-lg z-50 max-h-52 overflow-y-auto">
          {options.map(opt => (
            <div
              key={opt.value}
              className={`flex items-center gap-3 px-4 py-3 cursor-pointer hover:bg-muted transition-colors ${opt.value === value ? "text-primary font-medium" : "text-foreground"}`}
              onClick={() => { onChange(opt.value); setOpen(false); }}
            >
              {opt.icon && <span>{opt.icon}</span>}
              <span>{opt.label}</span>
              {opt.value === value && <Check size={14} className="mr-auto text-primary" />}
            </div>
          ))}
        </div>
      )}
      {error && <p className="text-xs text-destructive">{error}</p>}
    </div>
  );
}

// ─── AppErrorBanner ────────────────────────────────────────
export function AppErrorBanner({ message, onClose }: { message: string; onClose: () => void }) {
  return (
    <div className="flex items-start gap-3 p-3 rounded-xl" style={{ background: "var(--danger-bg)" }}>
      <AlertCircle size={18} className="shrink-0 mt-0.5" style={{ color: "var(--danger)" }} />
      <p className="flex-1 text-sm" style={{ color: "var(--danger)" }}>{message}</p>
      <button onClick={onClose} className="shrink-0 p-0.5" style={{ color: "var(--danger)" }}>
        <X size={16} />
      </button>
    </div>
  );
}

// ─── AppEmptyState ─────────────────────────────────────────
interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  subtitle?: string;
  action?: { label: string; onClick: () => void };
}
export function AppEmptyState({ icon, title, subtitle, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center gap-4 py-12 px-6 text-center">
      <div className="text-5xl">{icon ?? <PackageOpen size={48} className="text-muted-foreground" />}</div>
      <div>
        <p className="text-base font-medium text-foreground">{title}</p>
        {subtitle && <p className="text-sm text-muted-foreground mt-1">{subtitle}</p>}
      </div>
      {action && (
        <AppPrimaryButton onClick={action.onClick} fullWidth={false} className="px-8">
          {action.label}
        </AppPrimaryButton>
      )}
    </div>
  );
}

// ─── AppStatCard ───────────────────────────────────────────
interface StatCardProps {
  label: string;
  value: number;
  currency?: string;
  color?: "primary" | "secondary" | "foreground";
  className?: string;
}
export function AppStatCard({ label, value, currency = "ل.س", color = "foreground", className = "" }: StatCardProps) {
  const [displayed, setDisplayed] = useState(0);
  useEffect(() => {
    const start = Date.now();
    const duration = 700;
    const raf = () => {
      const elapsed = Date.now() - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      setDisplayed(Math.round(value * eased));
      if (progress < 1) requestAnimationFrame(raf);
    };
    requestAnimationFrame(raf);
  }, [value]);

  const colorClass = { primary: "text-primary", secondary: "text-secondary", foreground: "text-foreground" }[color];

  return (
    <AppCard className={className}>
      <p className="text-sm text-muted-foreground mb-1">{label}</p>
      <p className={`text-2xl font-medium ${colorClass}`} style={{ direction: "ltr", textAlign: "right" }}>
        {displayed.toLocaleString("ar-SY")} <span className="text-sm font-normal text-muted-foreground">{currency}</span>
      </p>
    </AppCard>
  );
}

// ─── SkeletonCard ──────────────────────────────────────────
export function SkeletonCard({ lines = 2 }: { lines?: number }) {
  return (
    <div className="bg-card border border-border rounded-xl p-4 flex flex-col gap-3">
      <div className="shimmer h-4 rounded-lg w-3/4" />
      {Array.from({ length: lines - 1 }).map((_, i) => (
        <div key={i} className="shimmer h-3 rounded-lg w-1/2" />
      ))}
    </div>
  );
}

// ─── BottomNav ─────────────────────────────────────────────
const NAV_ITEMS = [
  { key: "home", label: "الرئيسية", icon: "🏠" },
  { key: "transactions", label: "المعاملات", icon: "📋" },
  { key: "statistics", label: "الإحصاء", icon: "📊" },
  { key: "electricity", label: "الكهرباء", icon: "⚡" },
];

export function BottomNav({ current, onChange }: { current: string; onChange: (key: string) => void }) {
  const [ripple, setRipple] = useState<string | null>(null);

  const handleClick = (key: string) => {
    setRipple(key);
    setTimeout(() => setRipple(null), 400);
    onChange(key);
  };

  return (
    <nav className="flex items-center border-t border-border bg-card relative">
      {NAV_ITEMS.map(item => {
        const isActive = current === item.key;
        const isRippling = ripple === item.key;
        return (
          <button
            key={item.key}
            onClick={() => handleClick(item.key)}
            className="flex-1 flex flex-col items-center gap-1 py-2.5 relative overflow-hidden"
            style={{ color: isActive ? "var(--primary)" : "var(--muted-foreground)" }}
          >
            {/* Ripple background */}
            <span
              className="absolute inset-0 rounded-full"
              style={{
                background: "var(--primary)",
                opacity: isRippling ? 0.12 : 0,
                transform: isRippling ? "scale(2.5)" : "scale(0.5)",
                transition: isRippling
                  ? "transform 0.38s cubic-bezier(0.4,0,0.2,1), opacity 0.38s ease"
                  : "opacity 0.2s ease, transform 0s",
              }}
            />
            {/* Icon with bounce */}
            <span
              className="text-xl leading-none relative"
              style={{
                display: "block",
                transition: "transform 0.32s cubic-bezier(0.34,1.56,0.64,1)",
                transform: isActive ? "translateY(-3px) scale(1.18)" : "translateY(0) scale(1)",
              }}
            >
              {item.icon}
            </span>
            {/* Label */}
            <span
              className="text-[11px] font-medium relative"
              style={{
                transition: "opacity 0.2s ease, transform 0.2s ease",
                opacity: isActive ? 1 : 0.7,
              }}
            >
              {item.label}
            </span>
            {/* Active pill indicator */}
            <span
              style={{
                position: "absolute",
                bottom: 4,
                left: "50%",
                transform: "translateX(-50%)",
                width: isActive ? 20 : 0,
                height: 3,
                borderRadius: 99,
                background: "var(--primary)",
                transition: "width 0.3s cubic-bezier(0.34,1.56,0.64,1)",
              }}
            />
          </button>
        );
      })}
    </nav>
  );
}

// ─── PageHeader ────────────────────────────────────────────
export function PageHeader({ title, onBack, rightAction }: { title: string; onBack?: () => void; rightAction?: React.ReactNode }) {
  return (
    <header className="flex items-center gap-3 px-4 py-4 bg-card border-b border-border">
      {onBack && (
        <button onClick={onBack} className="w-10 h-10 flex items-center justify-center rounded-full hover:bg-muted transition-colors text-foreground">
          ‹
        </button>
      )}
      <h1 className="flex-1 text-lg font-medium text-foreground text-center">{title}</h1>
      <div className="w-10">{rightAction}</div>
    </header>
  );
}

// ─── TransactionItem ───────────────────────────────────────
import { useAppState } from "../store/AppContext";
import { Transaction } from "../data/mockData";

export function TransactionItem({ tx, onClick }: { tx: Transaction; onClick?: () => void }) {
  const { categories, currency } = useAppState();
  const cat = categories.find(c => c.id === tx.categoryId);
  const isIncome = tx.type === "income";
  const dateStr = new Date(tx.date).toLocaleDateString("ar-SY", { month: "short", day: "numeric" });

  return (
    <div
      onClick={onClick}
      className="flex items-center gap-3 py-3 px-1 border-b border-border last:border-0 cursor-pointer active:bg-muted/50 transition-colors rounded-lg"
    >
      <div className="w-10 h-10 rounded-full flex items-center justify-center text-lg" style={{ background: isIncome ? "rgba(107,142,107,0.15)" : "rgba(201,123,74,0.15)" }}>
        {cat?.icon ?? (isIncome ? "💰" : "📦")}
      </div>
      <div className="flex-1 min-w-0">
        <p className="text-sm font-medium text-foreground truncate">{cat?.name ?? "غير محدد"}</p>
        {tx.note && <p className="text-xs text-muted-foreground truncate">{tx.note}</p>}
        <p className="text-xs text-muted-foreground">{dateStr}</p>
      </div>
      <p className={`text-sm font-medium shrink-0 ${isIncome ? "text-primary" : "text-secondary"}`} style={{ direction: "ltr" }}>
        {isIncome ? "+" : "-"}{tx.amount.toLocaleString("ar-SY")} {currency}
      </p>
    </div>
  );
}
