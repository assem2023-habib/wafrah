import React, { createContext, useContext, useReducer, useEffect } from "react";
import {
  Category, Product, Transaction, ElectricityReading,
  defaultCategories, defaultProducts, defaultTransactions, defaultReadings,
} from "../data/mockData";

interface AppState {
  darkMode: boolean;
  categories: Category[];
  products: Product[];
  transactions: Transaction[];
  readings: ElectricityReading[];
  currency: string;
}

type Action =
  | { type: "TOGGLE_DARK" }
  | { type: "SET_CURRENCY"; payload: string }
  | { type: "ADD_TRANSACTION"; payload: Transaction }
  | { type: "UPDATE_TRANSACTION"; payload: Transaction }
  | { type: "DELETE_TRANSACTION"; payload: string }
  | { type: "ADD_CATEGORY"; payload: Category }
  | { type: "UPDATE_CATEGORY"; payload: Category }
  | { type: "DELETE_CATEGORY"; payload: string }
  | { type: "ADD_PRODUCT"; payload: Product }
  | { type: "UPDATE_PRODUCT"; payload: Product }
  | { type: "DELETE_PRODUCT"; payload: string }
  | { type: "ADD_READING"; payload: ElectricityReading }
  | { type: "DELETE_READING"; payload: string };

const initialState: AppState = {
  darkMode: false,
  categories: defaultCategories,
  products: defaultProducts,
  transactions: defaultTransactions,
  readings: defaultReadings,
  currency: "ل.س",
};

function reducer(state: AppState, action: Action): AppState {
  switch (action.type) {
    case "TOGGLE_DARK":
      return { ...state, darkMode: !state.darkMode };
    case "SET_CURRENCY":
      return { ...state, currency: action.payload };
    case "ADD_TRANSACTION":
      return { ...state, transactions: [action.payload, ...state.transactions] };
    case "UPDATE_TRANSACTION":
      return { ...state, transactions: state.transactions.map(t => t.id === action.payload.id ? action.payload : t) };
    case "DELETE_TRANSACTION":
      return { ...state, transactions: state.transactions.filter(t => t.id !== action.payload) };
    case "ADD_CATEGORY":
      return { ...state, categories: [...state.categories, action.payload] };
    case "UPDATE_CATEGORY":
      return { ...state, categories: state.categories.map(c => c.id === action.payload.id ? action.payload : c) };
    case "DELETE_CATEGORY":
      return { ...state, categories: state.categories.filter(c => c.id !== action.payload) };
    case "ADD_PRODUCT":
      return { ...state, products: [...state.products, action.payload] };
    case "UPDATE_PRODUCT":
      return { ...state, products: state.products.map(p => p.id === action.payload.id ? action.payload : p) };
    case "DELETE_PRODUCT":
      return { ...state, products: state.products.filter(p => p.id !== action.payload) };
    case "ADD_READING":
      return { ...state, readings: [...state.readings, action.payload].sort((a, b) => a.date.localeCompare(b.date)) };
    case "DELETE_READING":
      return { ...state, readings: state.readings.filter(r => r.id !== action.payload) };
    default:
      return state;
  }
}

const AppContext = createContext<{ state: AppState; dispatch: React.Dispatch<Action> } | null>(null);

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(reducer, initialState);

  useEffect(() => {
    document.documentElement.classList.toggle("dark", state.darkMode);
  }, [state.darkMode]);

  return <AppContext.Provider value={{ state, dispatch }}>{children}</AppContext.Provider>;
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error("useApp must be used within AppProvider");
  return ctx;
}

export function useAppState() {
  return useApp().state;
}

export function useAppDispatch() {
  return useApp().dispatch;
}

export function formatAmount(amount: number, currency: string = "ل.س") {
  return `${amount.toLocaleString("ar-SY")} ${currency}`;
}

export function generateId() {
  return Math.random().toString(36).slice(2) + Date.now().toString(36);
}
