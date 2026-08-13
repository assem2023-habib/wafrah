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

export default function AddExpenseScreen({ onBack, editId }: Props) {
  const state = useAppState();
  const dispatch = useAppDispatch();

  const existing = editId ? state.transactions.find(t => t.id === editId) : null;

  const [amount, setAmount] = useState(existing?.amount.toString() ?? "");
  const [categoryId, setCategoryId] = useState(existing?.categoryId ?? "");
  const [productId, setProductId] = useState(existing?.productId ?? "");
  const [date, setDate] = useState(existing?.date ?? new Date().toISOString().split("T")[0]);
  const [note, setNote] = useState(existing?.note ?? "");
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);

  const expenseCategories = state.categories.filter(c => c.type === "expense" || c.type === "both");
  const catOptions = expenseCategories.map(c => ({ value: c.id, label: c.name, icon: c.icon }));
  const products = state.products.filter(p => p.categoryId === categoryId);
  const productOptions = products.map(p => ({ value: p.id, label: p.name }));

  const handleSave = () => {
    setError("");
    if (!amount || parseInt(amount) === 0) return setError("يرجى إدخال مبلغ صحيح");
    if (!categoryId) return setError("يرجى اختيار التصنيف");
    if (!date) return setError("يرجى اختيار التاريخ");

    const tx = {
      id: editId ?? generateId(),
      type: "expense" as const,
      amount: parseInt(amount),
      categoryId,
      productId: productId || undefined,
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
      <PageHeader title={editId ? "تعديل المصروف" : "إضافة مصروف"} onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-5 flex flex-col gap-4">
        {error && <AppErrorBanner message={error} onClose={() => setError("")} />}
        <AppNumberField
          label="المبلغ"
          value={amount}
          onChange={setAmount}
          suffix={state.currency}
          error={!amount && error ? "مطلوب" : undefined}
        />
        <AppDropdownField
          label="التصنيف"
          value={categoryId}
          onChange={v => { setCategoryId(v); setProductId(""); }}
          options={catOptions}
          placeholder="اختر التصنيف"
        />
        {products.length > 0 && (
          <AppDropdownField
            label="المنتج (اختياري)"
            value={productId}
            onChange={setProductId}
            options={[{ value: "", label: "بدون منتج محدد" }, ...productOptions]}
          />
        )}
        <AppDateField label="التاريخ" value={date} onChange={setDate} />
        <AppTextField
          label="ملاحظة (اختياري)"
          value={note}
          onChange={e => setNote(e.target.value)}
          placeholder="أضف ملاحظة..."
        />
      </div>
      <div className="px-4 pb-6 pt-2 border-t border-border">
        <AppPrimaryButton variant="secondary" onClick={handleSave}>
          {editId ? "تحديث المصروف" : "حفظ المصروف"}
        </AppPrimaryButton>
      </div>
    </div>
  );
}
