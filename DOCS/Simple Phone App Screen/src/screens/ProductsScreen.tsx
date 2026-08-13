import React, { useState } from "react";
import { Plus, Edit3, Trash2, Check } from "lucide-react";
import { useAppState, useAppDispatch, generateId } from "../store/AppContext";
import { PageHeader, AppCard, AppPrimaryButton, AppTextField, AppDropdownField, AppErrorBanner, AppEmptyState } from "../components";

export default function ProductsScreen({ onBack }: { onBack: () => void }) {
  const state = useAppState();
  const dispatch = useAppDispatch();
  const [showForm, setShowForm] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [name, setName] = useState("");
  const [categoryId, setCategoryId] = useState("");
  const [error, setError] = useState("");

  const catOptions = state.categories
    .filter(c => c.type === "expense" || c.type === "both")
    .map(c => ({ value: c.id, label: c.name, icon: c.icon }));

  const openAdd = () => {
    setEditId(null); setName(""); setCategoryId(""); setError(""); setShowForm(true);
  };

  const openEdit = (id: string) => {
    const p = state.products.find(p => p.id === id)!;
    setEditId(id); setName(p.name); setCategoryId(p.categoryId); setError(""); setShowForm(true);
  };

  const handleSave = () => {
    if (!name.trim()) return setError("يرجى إدخال اسم المنتج");
    if (!categoryId) return setError("يرجى اختيار التصنيف");
    if (editId) {
      dispatch({ type: "UPDATE_PRODUCT", payload: { id: editId, name: name.trim(), categoryId } });
    } else {
      dispatch({ type: "ADD_PRODUCT", payload: { id: generateId(), name: name.trim(), categoryId } });
    }
    setShowForm(false);
  };

  const grouped = state.categories
    .filter(cat => state.products.some(p => p.categoryId === cat.id))
    .map(cat => ({ cat, products: state.products.filter(p => p.categoryId === cat.id) }));

  return (
    <div className="flex flex-col h-full">
      <PageHeader
        title="إدارة المنتجات"
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
            <p className="text-sm font-medium text-foreground mb-3">{editId ? "تعديل المنتج" : "منتج جديد"}</p>
            <div className="flex flex-col gap-3">
              <AppTextField label="اسم المنتج" value={name} onChange={e => setName(e.target.value)} placeholder="مثال: خبز" />
              <AppDropdownField label="التصنيف" value={categoryId} onChange={setCategoryId} options={catOptions} placeholder="اختر التصنيف" />
              <div className="flex gap-2">
                <AppPrimaryButton onClick={handleSave} className="flex-1"><Check size={16} /> حفظ</AppPrimaryButton>
                <button onClick={() => setShowForm(false)} className="flex-1 h-12 rounded-xl border border-border text-muted-foreground font-medium">إلغاء</button>
              </div>
            </div>
          </AppCard>
        )}

        {state.products.length === 0 && !showForm ? (
          <AppEmptyState title="لا توجد منتجات" subtitle="أضف منتجات لتسهيل تسجيل المصاريف" action={{ label: "إضافة منتج", onClick: openAdd }} />
        ) : (
          grouped.map(({ cat, products }) => (
            <div key={cat.id}>
              <p className="text-xs font-medium text-muted-foreground mb-2">{cat.icon} {cat.name}</p>
              <div className="flex flex-col gap-2">
                {products.map(p => (
                  <AppCard key={p.id} className="flex flex-row items-center gap-3 py-3">
                    <p className="flex-1 text-sm text-foreground">{p.name}</p>
                    <button onClick={() => openEdit(p.id)} className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-muted text-muted-foreground">
                      <Edit3 size={15} />
                    </button>
                    <button onClick={() => dispatch({ type: "DELETE_PRODUCT", payload: p.id })} className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-danger-bg text-muted-foreground hover:text-destructive">
                      <Trash2 size={15} />
                    </button>
                  </AppCard>
                ))}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
