import React from "react";
import { Moon, Sun, Tag, ShoppingBag, Download, Info } from "lucide-react";
import { useAppState, useAppDispatch } from "../store/AppContext";
import { PageHeader, AppCard } from "../components";

interface Props {
  onNavigate: (screen: string) => void;
  onBack: () => void;
}

export default function SettingsScreen({ onNavigate, onBack }: Props) {
  const state = useAppState();
  const dispatch = useAppDispatch();

  return (
    <div className="flex flex-col h-full">
      <PageHeader title="الإعدادات" onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-5 flex flex-col gap-4">

        {/* Appearance */}
        <div>
          <p className="text-xs font-medium text-muted-foreground mb-2 px-1">المظهر</p>
          <AppCard className="p-0">
            <SettingsRow
              icon={state.darkMode ? <Moon size={18} className="text-primary" /> : <Sun size={18} className="text-primary" />}
              label="الوضع الليلي"
              right={
                <button
                  onClick={() => dispatch({ type: "TOGGLE_DARK" })}
                  className={`w-12 h-6 rounded-full transition-colors relative ${state.darkMode ? "bg-primary" : "bg-muted"}`}
                >
                  <div className={`w-5 h-5 bg-white rounded-full absolute top-0.5 transition-all ${state.darkMode ? "right-0.5" : "left-0.5"}`} />
                </button>
              }
            />
          </AppCard>
        </div>

        {/* Data */}
        <div>
          <p className="text-xs font-medium text-muted-foreground mb-2 px-1">البيانات</p>
          <AppCard className="p-0">
            <SettingsRow
              icon={<Tag size={18} className="text-primary" />}
              label="إدارة التصنيفات"
              onClick={() => onNavigate("categories")}
              arrow
            />
            <SettingsRow
              icon={<ShoppingBag size={18} className="text-primary" />}
              label="إدارة المنتجات"
              onClick={() => onNavigate("products")}
              arrow
            />
          </AppCard>
        </div>

        {/* Export */}
        <div>
          <p className="text-xs font-medium text-muted-foreground mb-2 px-1">أخرى</p>
          <AppCard className="p-0">
            <SettingsRow
              icon={<Download size={18} className="text-primary" />}
              label="تصدير البيانات"
              onClick={() => alert("سيتوفر قريباً")}
              arrow
            />
            <SettingsRow
              icon={<Info size={18} className="text-primary" />}
              label="عن التطبيق"
              right={<span className="text-xs text-muted-foreground">الإصدار 1.0.0</span>}
            />
          </AppCard>
        </div>

        <p className="text-center text-xs text-muted-foreground mt-2">وِفرة — مصاريفك ودخلك بكل بساطة</p>
      </div>
    </div>
  );
}

function SettingsRow({ icon, label, right, onClick, arrow }: {
  icon: React.ReactNode;
  label: string;
  right?: React.ReactNode;
  onClick?: () => void;
  arrow?: boolean;
}) {
  return (
    <div
      onClick={onClick}
      className={`flex items-center gap-3 px-4 py-4 border-b border-border last:border-0 ${onClick ? "cursor-pointer hover:bg-muted/50 active:bg-muted" : ""} transition-colors`}
    >
      <span className="w-8 h-8 flex items-center justify-center rounded-lg bg-primary/10">{icon}</span>
      <span className="flex-1 text-sm font-medium text-foreground">{label}</span>
      {right && <span>{right}</span>}
      {arrow && <span className="text-muted-foreground text-lg">‹</span>}
    </div>
  );
}
