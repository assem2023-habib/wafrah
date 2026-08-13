import React, { useState, useCallback } from "react";
import { AppProvider } from "../store/AppContext";
import { BottomNav } from "../components";
import SplashScreen from "../screens/SplashScreen";
import HomeScreen from "../screens/HomeScreen";
import AddExpenseScreen from "../screens/AddExpenseScreen";
import AddIncomeScreen from "../screens/AddIncomeScreen";
import TransactionsScreen from "../screens/TransactionsScreen";
import TransactionDetailScreen from "../screens/TransactionDetailScreen";
import StatisticsScreen from "../screens/StatisticsScreen";
import ElectricityHomeScreen from "../screens/ElectricityHomeScreen";
import AddReadingScreen from "../screens/AddReadingScreen";
import ReadingLogScreen from "../screens/ReadingLogScreen";
import CategoriesScreen from "../screens/CategoriesScreen";
import ProductsScreen from "../screens/ProductsScreen";
import SettingsScreen from "../screens/SettingsScreen";

type Screen =
  | "splash"
  | "home"
  | "addExpense"
  | "addIncome"
  | "transactions"
  | "transactionDetail"
  | "statistics"
  | "electricity"
  | "addReading"
  | "readingLog"
  | "categories"
  | "products"
  | "settings";

const TAB_SCREENS: Screen[] = ["home", "transactions", "statistics", "electricity"];
const TAB_KEYS = ["home", "transactions", "statistics", "electricity"];

function currentTab(screen: Screen): string {
  if (screen === "home" || screen === "addExpense" || screen === "addIncome" || screen === "settings") return "home";
  if (screen === "transactions" || screen === "transactionDetail") return "transactions";
  if (screen === "statistics") return "statistics";
  if (screen === "electricity" || screen === "addReading" || screen === "readingLog") return "electricity";
  return "home";
}

function AppShell() {
  const [screen, setScreen] = useState<Screen>("splash");
  const [params, setParams] = useState<Record<string, unknown>>({});
  const [history, setHistory] = useState<Array<{ screen: Screen; params: Record<string, unknown> }>>([]);

  const navigate = useCallback((target: string, p: Record<string, unknown> = {}) => {
    setHistory(h => [...h, { screen, params }]);
    setScreen(target as Screen);
    setParams(p);
  }, [screen, params]);

  const goBack = useCallback(() => {
    if (history.length === 0) {
      setScreen("home");
      setParams({});
      return;
    }
    const prev = history[history.length - 1];
    setHistory(h => h.slice(0, -1));
    setScreen(prev.screen);
    setParams(prev.params);
  }, [history]);

  const handleTabChange = useCallback((key: string) => {
    setHistory([]);
    setScreen(key as Screen);
    setParams({});
  }, []);

  const showBottomNav = !["splash", "addExpense", "addIncome", "transactionDetail",
    "addReading", "readingLog", "categories", "products", "settings"].includes(screen);

  if (screen === "splash") {
    return (
      <div className="size-full bg-background">
        <SplashScreen onDone={() => { setScreen("home"); }} />
      </div>
    );
  }

  const renderScreen = () => {
    switch (screen) {
      case "home":
        return <HomeScreen onNavigate={navigate} />;
      case "addExpense":
        return <AddExpenseScreen onBack={goBack} editId={params.editId as string | undefined} />;
      case "addIncome":
        return <AddIncomeScreen onBack={goBack} editId={params.editId as string | undefined} />;
      case "transactions":
        return <TransactionsScreen onNavigate={navigate} onBack={goBack} />;
      case "transactionDetail":
        return (
          <TransactionDetailScreen
            txId={params.id as string}
            onBack={goBack}
            onEdit={(id, type) => navigate(type === "income" ? "addIncome" : "addExpense", { editId: id })}
          />
        );
      case "statistics":
        return <StatisticsScreen onBack={goBack} />;
      case "electricity":
        return <ElectricityHomeScreen onNavigate={navigate} onBack={goBack} />;
      case "addReading":
        return <AddReadingScreen onBack={goBack} />;
      case "readingLog":
        return <ReadingLogScreen onBack={goBack} />;
      case "categories":
        return <CategoriesScreen onNavigate={navigate} onBack={goBack} />;
      case "products":
        return <ProductsScreen onBack={goBack} />;
      case "settings":
        return <SettingsScreen onNavigate={navigate} onBack={goBack} />;
      default:
        return <HomeScreen onNavigate={navigate} />;
    }
  };

  return (
    <div className="size-full bg-background flex flex-col relative overflow-hidden">
      <div
        className="flex-1 overflow-hidden flex flex-col"
        key={screen}
        style={{ animation: "slide-up 0.25s ease-out" }}
      >
        {renderScreen()}
      </div>
      {showBottomNav && (
        <BottomNav current={currentTab(screen)} onChange={handleTabChange} />
      )}
    </div>
  );
}

export default function App() {
  return (
    <AppProvider>
      <div
        className="flex items-center justify-center min-h-screen bg-[#1a1a1a]"
        style={{ fontFamily: "'Cairo', sans-serif" }}
      >
        {/* Phone frame */}
        <div
          className="relative overflow-hidden shadow-2xl"
          style={{
            width: 390,
            height: 844,
            borderRadius: 44,
            border: "8px solid #333",
            background: "var(--background)",
          }}
        >
          {/* Status bar */}
          <div className="h-10 bg-card flex items-center justify-between px-6 shrink-0">
            <span className="text-xs font-medium text-foreground">9:41</span>
            <div className="flex items-center gap-1.5">
              <div className="w-4 h-2.5 border border-foreground rounded-sm relative opacity-70">
                <div className="absolute inset-0.5 right-1 bg-foreground rounded-sm" />
                <div className="absolute right-0 top-1/2 -translate-y-1/2 translate-x-full w-0.5 h-1.5 bg-foreground rounded-full" />
              </div>
              <div className="text-foreground opacity-70">
                <svg width="15" height="12" viewBox="0 0 15 12" fill="currentColor">
                  <path d="M7.5 0C3.36 0 0 2.24 0 5c0 1.66 1.07 3.13 2.73 4.1L1.5 12l2.97-1.49A9.2 9.2 0 007.5 11c4.14 0 7.5-2.24 7.5-5S11.64 0 7.5 0z" opacity=".3" />
                  <path d="M7.5 2C4.46 2 2 3.34 2 5s2.46 3 5.5 3 5.5-1.34 5.5-3-2.46-3-5.5-3z" />
                </svg>
              </div>
            </div>
          </div>

          {/* App content */}
          <div className="h-[calc(100%-40px)] overflow-hidden flex flex-col">
            <AppShell />
          </div>
        </div>
      </div>
    </AppProvider>
  );
}
