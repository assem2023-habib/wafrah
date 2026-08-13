import React from "react";
import { Trash2 } from "lucide-react";
import { useAppState, useAppDispatch } from "../store/AppContext";
import { PageHeader, AppEmptyState, AppCard } from "../components";

export default function ReadingLogScreen({ onBack }: { onBack: () => void }) {
  const state = useAppState();
  const dispatch = useAppDispatch();
  const readings = [...state.readings].sort((a, b) => b.date.localeCompare(a.date));

  return (
    <div className="flex flex-col h-full">
      <PageHeader title="سجل القراءات" onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-4 flex flex-col gap-3">
        {readings.length === 0 ? (
          <AppEmptyState
            icon={<span className="text-5xl">📊</span>}
            title="لا توجد قراءات بعد"
            subtitle="أضف قراءة من شاشة الكهرباء"
          />
        ) : (
          readings.map((r, i) => (
            <AppCard key={r.id} className="flex flex-row items-center gap-3">
              <div className="flex-1">
                <p className="text-xs text-muted-foreground mb-1">
                  {new Date(r.date).toLocaleDateString("ar-SY", { year: "numeric", month: "long", day: "numeric" })}
                </p>
                <div className="grid grid-cols-3 gap-2 mt-2">
                  <div>
                    <p className="text-xs text-muted-foreground">القراءة</p>
                    <p className="text-sm font-medium text-foreground">{r.value} ك.و</p>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground">الاستهلاك</p>
                    <p className="text-sm font-medium text-primary">{r.consumption} ك.و</p>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground">التكلفة</p>
                    <p className="text-sm font-medium text-secondary">{r.cost.toLocaleString("ar-SY")}</p>
                  </div>
                </div>
              </div>
              {i !== readings.length - 1 && (
                <button
                  onClick={() => dispatch({ type: "DELETE_READING", payload: r.id })}
                  className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-danger-bg text-muted-foreground hover:text-destructive transition-colors shrink-0"
                >
                  <Trash2 size={16} />
                </button>
              )}
            </AppCard>
          ))
        )}
      </div>
    </div>
  );
}
