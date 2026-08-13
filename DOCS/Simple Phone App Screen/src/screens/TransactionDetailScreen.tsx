import React, { useState } from "react";
import { Trash2, Edit3 } from "lucide-react";
import { useAppState, useAppDispatch, formatAmount } from "../store/AppContext";
import { PageHeader, AppCard, AppPrimaryButton, AppSecondaryButton } from "../components";

interface Props {
  txId: string;
  onBack: () => void;
  onEdit: (id: string, type: string) => void;
}

export default function TransactionDetailScreen({ txId, onBack, onEdit }: Props) {
  const state = useAppState();
  const dispatch = useAppDispatch();
  const [confirmDelete, setConfirmDelete] = useState(false);

  const tx = state.transactions.find(t => t.id === txId);
  if (!tx) return (
    <div className="flex flex-col h-full">
      <PageHeader title="تفاصيل المعاملة" onBack={onBack} />
      <div className="flex-1 flex items-center justify-center">
        <p className="text-muted-foreground">المعاملة غير موجودة</p>
      </div>
    </div>
  );

  const cat = state.categories.find(c => c.id === tx.categoryId);
  const product = tx.productId ? state.products.find(p => p.id === tx.productId) : null;
  const isIncome = tx.type === "income";

  const handleDelete = () => {
    dispatch({ type: "DELETE_TRANSACTION", payload: tx.id });
    onBack();
  };

  return (
    <div className="flex flex-col h-full">
      <PageHeader title="تفاصيل المعاملة" onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-5 flex flex-col gap-4">

        {/* Amount hero */}
        <div className={`rounded-2xl p-6 flex flex-col items-center gap-2 ${isIncome ? "bg-primary/10" : "bg-secondary/10"}`}>
          <div className="w-16 h-16 rounded-full flex items-center justify-center text-3xl" style={{ background: isIncome ? "rgba(107,142,107,0.2)" : "rgba(201,123,74,0.2)" }}>
            {cat?.icon ?? "📦"}
          </div>
          <p className={`text-3xl font-medium ${isIncome ? "text-primary" : "text-secondary"}`} style={{ direction: "ltr" }}>
            {isIncome ? "+" : "-"}{tx.amount.toLocaleString("ar-SY")} {state.currency}
          </p>
          <span className={`text-sm px-3 py-1 rounded-full font-medium ${isIncome ? "bg-primary/20 text-primary" : "bg-secondary/20 text-secondary"}`}>
            {isIncome ? "دخل" : "مصروف"}
          </span>
        </div>

        {/* Details */}
        <AppCard>
          <div className="flex flex-col gap-3">
            <DetailRow label="التصنيف" value={`${cat?.icon ?? ""} ${cat?.name ?? "غير محدد"}`} />
            {product && <DetailRow label="المنتج" value={product.name} />}
            <DetailRow label="التاريخ" value={new Date(tx.date).toLocaleDateString("ar-SY", { year: "numeric", month: "long", day: "numeric" })} />
            {tx.note && <DetailRow label="الملاحظة" value={tx.note} />}
          </div>
        </AppCard>

        {/* Actions */}
        <AppSecondaryButton onClick={() => onEdit(tx.id, tx.type)} fullWidth>
          <Edit3 size={16} /> تعديل المعاملة
        </AppSecondaryButton>

        {confirmDelete ? (
          <div className="flex flex-col gap-2">
            <p className="text-sm text-center text-muted-foreground">هل أنت متأكد من حذف هذه المعاملة؟</p>
            <div className="grid grid-cols-2 gap-2">
              <AppPrimaryButton variant="danger" onClick={handleDelete} fullWidth>تأكيد الحذف</AppPrimaryButton>
              <AppSecondaryButton onClick={() => setConfirmDelete(false)} fullWidth>إلغاء</AppSecondaryButton>
            </div>
          </div>
        ) : (
          <button
            onClick={() => setConfirmDelete(true)}
            className="flex items-center justify-center gap-2 h-12 rounded-xl border border-destructive text-destructive text-base font-medium hover:bg-danger-bg active:scale-95 transition-all"
          >
            <Trash2 size={16} /> حذف المعاملة
          </button>
        )}
      </div>
    </div>
  );
}

function DetailRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-4 py-1">
      <span className="text-sm text-muted-foreground shrink-0">{label}</span>
      <span className="text-sm text-foreground font-medium text-left">{value}</span>
    </div>
  );
}
