import React, { useState } from "react";
import { Check } from "lucide-react";
import { useAppState, useAppDispatch, generateId } from "../store/AppContext";
import { PageHeader, AppNumberField, AppDateField, AppPrimaryButton, AppErrorBanner, AppCard } from "../components";

export default function AddReadingScreen({ onBack }: { onBack: () => void }) {
  const state = useAppState();
  const dispatch = useAppDispatch();
  const prevReading = state.readings[state.readings.length - 1];

  const [value, setValue] = useState("");
  const [date, setDate] = useState(new Date().toISOString().split("T")[0]);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const numValue = parseInt(value) || 0;
  const consumption = prevReading ? Math.max(0, numValue - prevReading.value) : 0;
  const RATE = 300;
  const cost = consumption * RATE;

  const handleSave = () => {
    setError("");
    if (!value || numValue === 0) return setError("يرجى إدخال قراءة صحيحة");
    if (prevReading && numValue < prevReading.value) return setError(`القراءة الجديدة يجب أن تكون أكبر من القراءة السابقة (${prevReading.value} ك.و)`);
    if (!date) return setError("يرجى اختيار التاريخ");

    dispatch({
      type: "ADD_READING",
      payload: { id: generateId(), value: numValue, date, consumption, cost },
    });
    setSuccess(true);
    setTimeout(onBack, 1200);
  };

  if (success) {
    return (
      <div className="flex flex-col items-center justify-center h-full bg-background gap-4">
        <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center" style={{ animation: "scale-in 0.3s ease-out" }}>
          <Check size={40} className="text-primary" />
        </div>
        <p className="text-lg font-medium text-foreground">تم تسجيل القراءة!</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full">
      <PageHeader title="إضافة قراءة كهرباء" onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-5 flex flex-col gap-4">
        {error && <AppErrorBanner message={error} onClose={() => setError("")} />}

        {prevReading && (
          <AppCard>
            <p className="text-xs text-muted-foreground mb-1">القراءة السابقة</p>
            <p className="text-xl font-medium text-foreground">{prevReading.value} <span className="text-sm font-normal text-muted-foreground">ك.و</span></p>
            <p className="text-xs text-muted-foreground mt-1">{new Date(prevReading.date).toLocaleDateString("ar-SY", { year: "numeric", month: "long", day: "numeric" })}</p>
          </AppCard>
        )}

        <AppNumberField
          label="القراءة الجديدة"
          value={value}
          onChange={setValue}
          suffix="ك.و"
          placeholder="0"
        />

        {value && parseInt(value) > 0 && (
          <AppCard className="bg-primary/5 border-primary/20">
            <p className="text-sm font-medium text-foreground mb-2">الاستهلاك المحسوب</p>
            <div className="flex items-center justify-between">
              <span className="text-sm text-muted-foreground">الاستهلاك</span>
              <span className="text-sm font-medium text-primary">{consumption} ك.و</span>
            </div>
            <div className="flex items-center justify-between mt-1">
              <span className="text-sm text-muted-foreground">التكلفة التقريبية</span>
              <span className="text-sm font-medium text-secondary">{cost.toLocaleString("ar-SY")} {state.currency}</span>
            </div>
          </AppCard>
        )}

        <AppDateField label="تاريخ القراءة" value={date} onChange={setDate} />
      </div>
      <div className="px-4 pb-6 pt-2 border-t border-border">
        <AppPrimaryButton onClick={handleSave}>حفظ القراءة</AppPrimaryButton>
      </div>
    </div>
  );
}
