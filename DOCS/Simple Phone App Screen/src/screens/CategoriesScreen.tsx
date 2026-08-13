import React, { useState } from "react";
import { Plus, Edit3, Trash2, X, Check } from "lucide-react";
import { useAppState, useAppDispatch, generateId } from "../store/AppContext";
import { PageHeader, AppCard, AppPrimaryButton, AppTextField, AppDropdownField, AppErrorBanner, AppEmptyState } from "../components";

const ICONS = ["🍽️", "🚗", "💊", "🏠", "⚡", "🛍️", "🎬", "📦", "💼", "🏦", "🎁", "💰", "📱", "👗", "🎓", "⚽", "🐾", "✈️", "🏋️", "💻"];

export default function CategoriesScreen({ onNavigate, onBack }: { onNavigate: (s: string) => void; onBack: () => void }) {
  const state = useAppState();
  const dispatch = useAppDispatch();
  const [showForm, setShowForm] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [name, setName] = useState("");
  const [icon, setIcon] = useState("📦");
  const [type, setType] = useState<"expense" | "income" | "both">("expense");
  const [error, setError] = useState("");

  const typeOptions = [
    { value: "expense", label: "مصروف" },
    { value: "income", label: "دخل" },
    { value: "both", label: "كلاهما" },
  ];

  const openAdd = () => {
    setEditId(null);
    setName("");
    setIcon("📦");
    setType("expense");
    setError("");
    setShowForm(true);
  };

  const openEdit = (catId: string) => {
    const cat = state.categories.find(c => c.id === catId)!;
    setEditId(catId);
    setName(cat.name);
    setIcon(cat.icon);
    setType(cat.type);
    setError("");
    setShowForm(true);
  };

  const handleSave = () => {
    setError("");
    if (!name.trim()) return setError("يرجى إدخال اسم التصنيف");
    if (editId) {
      dispatch({ type: "UPDATE_CATEGORY", payload: { id: editId, name: name.trim(), icon, type } });
    } else {
      dispatch({ type: "ADD_CATEGORY", payload: { id: generateId(), name: name.trim(), icon, type } });
    }
    setShowForm(false);
  };

  const handleDelete = (catId: string) => {
    const hasTransactions = state.transactions.some(t => t.categoryId === catId);
    if (hasTransactions) {
      setError("لا يمكن حذف تصنيف له معاملات");
      return;
    }
    dispatch({ type: "DELETE_CATEGORY", payload: catId });
  };

  return (
    <div className="flex flex-col h-full">
      <PageHeader
        title="إدارة التصنيفات"
        onBack={onBack}
        rightAction={
          <button onClick={openAdd} className="w-10 h-10 flex items-center justify-center rounded-full bg-primary text-primary-foreground">
            <Plus size={18} />
          </button>
        }
      />
      <div className="flex-1 overflow-y-auto px-4 py-4 flex flex-col gap-3">
        {error && <AppErrorBanner message={error} onClose={() => setError("")} />}

        {showForm && (
          <AppCard>
            <p className="text-sm font-medium text-foreground mb-3">{editId ? "تعديل التصنيف" : "تصنيف جديد"}</p>
            <div className="flex flex-col gap-3">
              <AppTextField label="اسم التصنيف" value={name} onChange={e => setName(e.target.value)} placeholder="مثال: طعام" />
              <div>
                <label className="text-sm font-medium text-foreground mb-1 block">الأيقونة</label>
                <div className="flex flex-wrap gap-2">
                  {ICONS.map(ic => (
                    <button
                      key={ic}
                      onClick={() => setIcon(ic)}
                      className={`w-10 h-10 text-xl rounded-lg flex items-center justify-center transition-colors ${icon === ic ? "bg-primary/20 ring-2 ring-primary" : "bg-muted hover:bg-muted/80"}`}
                    >
                      {ic}
                    </button>
                  ))}
                </div>
              </div>
              <AppDropdownField
                label="النوع"
                value={type}
                onChange={v => setType(v as typeof type)}
                options={typeOptions}
              />
              <div className="flex gap-2">
                <AppPrimaryButton onClick={handleSave} className="flex-1">
                  <Check size={16} /> حفظ
                </AppPrimaryButton>
                <button onClick={() => setShowForm(false)} className="flex-1 h-12 rounded-xl border border-border text-muted-foreground font-medium">
                  إلغاء
                </button>
              </div>
            </div>
          </AppCard>
        )}

        {state.categories.length === 0 ? (
          <AppEmptyState title="لا توجد تصنيفات" action={{ label: "إضافة تصنيف", onClick: openAdd }} />
        ) : (
          state.categories.map(cat => (
            <AppCard key={cat.id} className="flex flex-row items-center gap-3 py-3">
              <div className="w-10 h-10 rounded-full flex items-center justify-center text-xl bg-muted">{cat.icon}</div>
              <div className="flex-1">
                <p className="text-sm font-medium text-foreground">{cat.name}</p>
                <p className="text-xs text-muted-foreground">{typeOptions.find(o => o.value === cat.type)?.label}</p>
              </div>
              <button onClick={() => openEdit(cat.id)} className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-muted text-muted-foreground">
                <Edit3 size={16} />
              </button>
              <button onClick={() => handleDelete(cat.id)} className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-danger-bg text-muted-foreground hover:text-destructive">
                <Trash2 size={16} />
              </button>
            </AppCard>
          ))
        )}
      </div>
    </div>
  );
}
