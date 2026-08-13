import React, { useMemo } from "react";
import { Plus, List, Zap } from "lucide-react";
import { useAppState } from "../store/AppContext";
import { PageHeader, AppCard, AppPrimaryButton, AppSecondaryButton, AppEmptyState } from "../components";

interface Props {
  onNavigate: (screen: string) => void;
  onBack: () => void;
}

export default function ElectricityHomeScreen({ onNavigate, onBack }: Props) {
  const state = useAppState();
  const readings = state.readings;

  const latest = readings[readings.length - 1];
  const prev = readings[readings.length - 2];

  const maxConsumption = 300;
  const consumption = latest?.consumption ?? 0;
  const progress = Math.min(consumption / maxConsumption, 1);
  const isWarning = consumption > maxConsumption * 0.8;

  const circumference = 2 * Math.PI * 54;
  const dash = progress * circumference;

  return (
    <div className="flex flex-col h-full">
      <PageHeader title="قسم الكهرباء" onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-5 flex flex-col gap-4">
        {readings.length < 2 ? (
          <AppEmptyState
            icon={<span className="text-5xl">⚡</span>}
            title="لا توجد قراءات بعد"
            subtitle="أضف قراءتين على الأقل لحساب الاستهلاك"
            action={{ label: "إضافة قراءة", onClick: () => onNavigate("addReading") }}
          />
        ) : (
          <>
            {/* Circular meter */}
            <AppCard className="flex flex-col items-center py-6">
              <div className="relative w-36 h-36 flex items-center justify-center">
                <svg width="144" height="144" viewBox="0 0 144 144" style={{ transform: "rotate(-90deg)" }}>
                  <circle cx="72" cy="72" r="54" fill="none" stroke="var(--muted)" strokeWidth="10" />
                  <circle
                    cx="72" cy="72" r="54" fill="none"
                    stroke={isWarning ? "var(--danger)" : "var(--primary)"}
                    strokeWidth="10"
                    strokeLinecap="round"
                    strokeDasharray={`${dash} ${circumference}`}
                    style={{
                      transition: "stroke-dasharray 0.7s ease",
                      animation: isWarning ? "warn-pulse 0.9s infinite" : undefined,
                    }}
                  />
                </svg>
                <div className="absolute inset-0 flex flex-col items-center justify-center">
                  <Zap size={20} className={isWarning ? "text-destructive" : "text-primary"} />
                  <p className={`text-2xl font-medium ${isWarning ? "text-destructive" : "text-foreground"}`}>{consumption}</p>
                  <p className="text-xs text-muted-foreground">ك.و</p>
                </div>
              </div>
              <p className="text-sm font-medium text-foreground mt-3">استهلاك هذا الشهر</p>
              {isWarning && (
                <p className="text-xs text-destructive mt-1 font-medium">⚠️ الاستهلاك مرتفع</p>
              )}
            </AppCard>

            {/* Stats grid */}
            <div className="grid grid-cols-2 gap-3">
              <AppCard>
                <p className="text-xs text-muted-foreground mb-1">التكلفة المقدرة</p>
                <p className="text-base font-medium text-secondary" style={{ direction: "ltr", textAlign: "right" }}>
                  {(latest?.cost ?? 0).toLocaleString("ar-SY")}
                </p>
                <p className="text-xs text-muted-foreground">{state.currency}</p>
              </AppCard>
              <AppCard>
                <p className="text-xs text-muted-foreground mb-1">القراءة الأخيرة</p>
                <p className="text-base font-medium text-foreground">{latest?.value ?? 0}</p>
                <p className="text-xs text-muted-foreground">ك.و</p>
              </AppCard>
            </div>

            {/* Comparison */}
            {prev && (
              <AppCard>
                <p className="text-sm font-medium text-foreground mb-3">مقارنة بالشهر السابق</p>
                <div className="flex items-center justify-between">
                  <div className="text-center">
                    <p className="text-xs text-muted-foreground mb-1">الشهر السابق</p>
                    <p className="text-lg font-medium text-foreground">{prev.consumption} ك.و</p>
                  </div>
                  <div className="flex flex-col items-center">
                    <div className={`text-sm font-medium px-2 py-1 rounded-lg ${consumption > prev.consumption ? "text-destructive bg-danger-bg" : "text-primary bg-primary/10"}`}>
                      {consumption > prev.consumption ? "▲" : "▼"} {Math.abs(consumption - prev.consumption)} ك.و
                    </div>
                  </div>
                  <div className="text-center">
                    <p className="text-xs text-muted-foreground mb-1">هذا الشهر</p>
                    <p className={`text-lg font-medium ${isWarning ? "text-destructive" : "text-primary"}`}>{consumption} ك.و</p>
                  </div>
                </div>
              </AppCard>
            )}

            {/* Actions */}
            <AppPrimaryButton onClick={() => onNavigate("addReading")}>
              <Plus size={18} /> إضافة قراءة جديدة
            </AppPrimaryButton>
            <AppSecondaryButton onClick={() => onNavigate("readingLog")}>
              <List size={18} /> عرض سجل القراءات
            </AppSecondaryButton>
          </>
        )}

      </div>
    </div>
  );
}
