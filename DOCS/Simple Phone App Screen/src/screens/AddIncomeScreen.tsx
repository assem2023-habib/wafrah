import React, { useState } from "react";
import { Check } from "lucide-react";
import { useAppState, useAppDispatch, generateId } from "../store/AppContext";
import {
  PageHeader, AppNumberField, AppDropdownField, AppDateField,
  AppTextField, AppPrimaryButton, AppErrorBanner,
} from "../components";

interface Props {
  onBack: () => void;
  editId?: string;
}

export default function AddIncomeScreen({ onBack, editId }: Props) {
  const state = useAppState();
  const dispatch = useAppDispatch();

  const existing = editId ? state.transactions.find(t => t.id === editId) : null;

  const [amount, setAmount] = useState(existing?.amount.toString() ?? "");
  const [categoryId, setCategoryId] = useState(existing?.categoryId ?? "");
  const [date, setDate] = useState(existing?.date ?? new Date().toISOString().split("T")[0]);
  const [note, setNote] = useState(existing?.note ?? "");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const incomeCategories = state.categories.filter(c => c.type === "income" || c.type === "both");
  const catOptions = incomeCategories.map(c => ({ value: c.id, label: c.name, icon: c.icon }));

  const handleSave = () => {
    setError("");
    if (!amount || parseInt(amount) === 0) return setError("يرجى إدخال مبلغ صحيح");
    if (!categoryId) return setError("يرجى اختيار التصنيف");
    if (!date) return setError("يرجى اختيار التاريخ");

    const tx = {
      id: editId ?? generateId(),
      type: "income" as const,
      amount: parseInt(amount),
      categoryId,
      date,
      note: note || undefined,
    };

    if (editId) {
      dispatch({ type: "UPDATE_TRANSACTION", payload: tx });
    } else {
      dispatch({ type: "ADD_TRANSACTION", payload: tx });
    }

    setSuccess(true);
    setTimeout(onBack, 1200);
  };

  if (success) {
    return (
      <div className="flex flex-col items-center justify-center h-full bg-background gap-4">
        <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center" style={{ animation: "scale-in 0.3s ease-out" }}>
          <Check size={40} className="text-primary" />
        </div>
        <p className="text-lg font-medium text-foreground">تم الحفظ بنجاح!</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full">
      <PageHeader title={editId ? "تعديل الدخل" : "إضافة دخل"} onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-5 flex flex-col gap-4">
        {error && <AppErrorBanner message={error} onClose={() => setError("")} />}
        <AppNumberField
          label="المبلغ"
          value={amount}
          onChange={setAmount}
          suffix={state.currency}
        />
        <AppDropdownField
          label="التصنيف"
          value={categoryId}
          onChange={setCategoryId}
          options={catOptions}
          placeholder="اختر التصنيف"
        />
        <AppDateField label="التاريخ" value={date} onChange={setDate} />
        <AppTextField
          label="ملاحظة (اختياري)"
          value={note}
          onChange={e => setNote(e.target.value)}
          placeholder="أضف ملاحظة..."
        />
      </div>
      <div className="px-4 pb-6 pt-2 border-t border-border">
        <AppPrimaryButton variant="primary" onClick={handleSave}>
          {editId ? "تحديث الدخل" : "حفظ الدخل"}
        </AppPrimaryButton>
      </div>
    </div>
  );
}
