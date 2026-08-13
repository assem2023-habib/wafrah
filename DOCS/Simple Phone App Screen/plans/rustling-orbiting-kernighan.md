# خطة تطوير تطبيق وِفرة — Wifra Finance App

## Context
بناء واجهة React كاملة لتطبيق وِفرة، وهو تطبيق تتبع مالي شخصي مستهدف لكبار السن. التطبيق عربي RTL بالكامل، يعمل بتخطيط هاتف محمول (390×844px). لا توجد خلفية حقيقية — كل البيانات وهمية في الذاكرة باستخدام React state.

---

## 1. الهوية البصرية وقاموس الألوان

### الألوان — Light Mode (الافتراضي)
| Token | Value | الاستخدام |
|---|---|---|
| `background` | `#F7F4EE` | خلفية التطبيق العامة (كريمي دافئ) |
| `surface` | `#FFFFFF` | بطاقات، حقول إدخال |
| `primary` | `#6B8E6B` | أخضر مريمي — الدخل، العناصر الإيجابية، الأزرار الرئيسية |
| `secondary` | `#C97B4A` | تيراكوتا — المصاريف، التمييز، النقطة في الشعار |
| `textPrimary` | `#2E2C28` | النصوص الرئيسية |
| `textSecondary` | `#7A7568` | النصوص الثانوية، الأوصاف |
| `border` | `#D3D1C7` | حدود البطاقات والحقول |
| `danger` | `#B8503F` | الأخطاء |
| `dangerBg` | `#F3D9D3` | خلفية رسائل الخطأ |

### الألوان — Dark Mode
| Token | Value |
|---|---|
| `background` | `#1E1D1A` |
| `surface` | `#2A2925` |
| `primary` | `#8FB08F` |
| `secondary` | `#D99568` |
| `textPrimary` | `#EDEAE2` |
| `textSecondary` | `#A8A398` |
| `border` | `#413F38` |
| `danger` | `#D97862` |
| `dangerBg` | `#3A2C27` |

### الخط
- **Cairo** من Google Fonts — وزنان فقط: 400 (عادي) + 500 (عناوين/أزرار)
- لا يُستخدم Bold (700) في أي مكان
- حجم body: 16px، label: 14px، heading: 20–22px، stat: 28–32px
- line-height: 1.5 دائماً

---

## 2. المقاسات (Dimension Tokens)

```
padding:  xs=4  sm=8  md=16  lg=24  xl=32
gap:      xs=4  sm=8  md=12  lg=20
radius:   sm=8  md=12  lg=16  full=9999
heights:  button=48px  field=52px  touch_min=44px
icons:    sm=16  md=20  lg=28  xl=40
borders:  thin=0.5px  default=1px
```

---

## 3. بنية الملفات المقترحة

```
src/
├── app/
│   └── App.tsx               ← نقطة الدخل + Router
├── styles/
│   ├── fonts.css             ← import Cairo من Google Fonts
│   └── theme.css             ← تحديث tokens بالألوان أعلاه
├── components/               ← المكوّنات المشتركة
│   ├── AppCard.tsx
│   ├── AppTextField.tsx
│   ├── AppNumberField.tsx
│   ├── AppDateField.tsx
│   ├── AppDropdownField.tsx
│   ├── AppPrimaryButton.tsx
│   ├── AppSecondaryButton.tsx
│   ├── AppErrorBanner.tsx
│   ├── AppEmptyState.tsx
│   ├── AppStatCard.tsx
│   ├── BottomNav.tsx
│   └── SkeletonCard.tsx
├── screens/
│   ├── SplashScreen.tsx      ← شاشة البداية مع الأنيميشن
│   ├── HomeScreen.tsx        ← Dashboard
│   ├── AddExpenseScreen.tsx
│   ├── AddIncomeScreen.tsx
│   ├── TransactionsScreen.tsx
│   ├── TransactionDetailScreen.tsx
│   ├── CategoriesScreen.tsx
│   ├── ProductsScreen.tsx
│   ├── StatisticsScreen.tsx
│   ├── ElectricityHomeScreen.tsx
│   ├── AddReadingScreen.tsx
│   ├── ReadingLogScreen.tsx
│   └── SettingsScreen.tsx
├── store/
│   └── useAppStore.ts        ← Zustand store (بيانات وهمية)
└── data/
    └── mockData.ts           ← بيانات تجريبية
```

---

## 4. إدارة الحالة والتنقل

- **React Router v6** للتنقل بين الشاشات (بدلاً من Flutter GetX)
- **Zustand** لإدارة الحالة العامة (معاملات، إعدادات، الوضع الليلي)
- لا يوجد خادم خلفي — كل البيانات في Zustand مع بيانات وهمية مبدئية
- التنقل يحاكي سلوك تطبيق الهاتف: Splash → Home، ثم Bottom Navigation

---

## 5. الشاشات الاثنتا عشرة

### 5.1 Splash Screen
- خلفية `background`، دائرة `primary`، أيقونة محفظة بخط `background`
- نقطة `secondary` على المحفظة
- نص "وِفرة" + "جاري التحميل..."
- 3 نقاط تنبض (pulse: opacity + scale، 1.2s، stagger 0.15s)
- بعد 2.5s تنتقل تلقائياً إلى Home

### 5.2 Home / Dashboard
**حالة عادية:**
- Header: اسم التطبيق + أيقونة إعدادات + toggle الوضع الليلي
- بطاقة رئيسية: الرصيد الكلي (count-up animation) + الفترة الزمنية
- صفان: إجمالي الدخل (أخضر) | إجمالي المصاريف (تيراكوتا)
- آخر 5 معاملات (بطاقات مع stagger animation)
- زر عائم (+) لإضافة معاملة
- Bottom Nav: الرئيسية، المعاملات، الإحصاء، الكهرباء

**حالة فارغة:** رسالة ترحيب + "أضف أول معاملة" (بدون أرقام مضللة)
**حالة تحميل:** shimmer skeleton على البطاقات

### 5.3 Add Expense
- حقل المبلغ (AppNumberField، 28px، suffix "ل.س")
- حقل التصنيف (AppDropdownField)
- حقل المنتج (يظهر فقط إذا اختير تصنيف له منتجات)
- حقل التاريخ (AppDateField)
- حقل الملاحظة (اختياري)
- AppPrimaryButton "حفظ المصروف" (لون secondary/تيراكوتا)
- AppErrorBanner لأخطاء التحقق
- عند النجاح: checkmark scale-in → العودة للرئيسية

### 5.4 Add Income
- نفس بنية Add Expense لكن:
- AppPrimaryButton بلون primary/أخضر
- لا يوجد حقل منتج
- تصنيفات الدخل فقط

### 5.5 Transaction Log
- شريط بحث + فلتر (التصنيف، الفترة، النوع)
- قائمة معاملات مجمّعة بالتاريخ
- 3 حالات فراغ: فارغ كلياً / فلتر بلا نتائج / خطأ
- الضغط على معاملة → TransactionDetail

### 5.6 Transaction Detail
- عرض كامل للمعاملة
- زر حذف (danger color، تأكيد قبل الحذف)
- زر تعديل (يفتح نفس شاشة الإضافة مع البيانات محملة مسبقاً)

### 5.7 Category Management
- قائمة التصنيفات مع أيقوناتها
- إضافة / تعديل / حذف
- لا يُحذف تصنيف له معاملات (AppErrorBanner)

### 5.8 Product Management
- منتجات مرتبطة بتصنيف
- إضافة / تعديل / حذف

### 5.9 Statistics
- مخطط دائري (Recharts PieChart) للمصاريف بالتصنيفات — ألوان من primary/secondary palette
- مخطط شريطي (BarChart) للدخل/المصاريف شهرياً
- chart growth animation عند التحميل
- فلتر: هذا الشهر / 3 أشهر / 6 أشهر / سنة

### 5.10 Electricity Home
- عداد طاقة دائري (CSS animation) يُظهر استهلاك الشهر الحالي
- بطاقة: الاستهلاك الكلي بالكيلوواط + التكلفة المقدرة
- مقارنة بالشهر السابق
- زر "إضافة قراءة" + "عرض السجل"
- حالة تحذير pulse إذا الاستهلاك > حد معين

### 5.11 Add Reading
- حقل القراءة الجديدة (كيلوواط)
- عرض القراءة السابقة للمقارنة
- حساب الاستهلاك تلقائياً
- حقل التاريخ

### 5.12 Reading Log
- قائمة القراءات مرتبة زمنياً
- عمود: التاريخ، القراءة، الاستهلاك، التكلفة

### 5.13 Settings
- toggle الوضع الليلي (يطبق dark class على الـ root)
- عملة العرض (ل.س افتراضي)
- تصدير البيانات (وهمي)
- عن التطبيق: الإصدار + اسم المطوّر

---

## 6. المكوّنات المشتركة (Shared Widgets)

| المكوّن | الوصف |
|---|---|
| `AppCard` | `bg-surface border border-border rounded-lg p-4` |
| `AppTextField` | حقل مع label علوي، خطأ سفلي |
| `AppNumberField` | رقمي 20px، تنسيق آلاف، suffix ثابت |
| `AppDateField` | يفتح native date picker بألوان التطبيق |
| `AppDropdownField` | Radix Select مع أيقونات |
| `AppPrimaryButton` | h-12 rounded-lg، shrink animation onPress |
| `AppSecondaryButton` | variant outline، border primary |
| `AppErrorBanner` | bg-dangerBg، text-danger، X يدوي |
| `AppEmptyState` | أيقونة + نص + زر CTA اختياري |
| `AppStatCard` | رقم count-up + label |
| `SkeletonCard` | shimmer animation على بطاقة وهمية |
| `BottomNav` | 4 أيقونات، active = primary color |

---

## 7. الأنيميشن

| الأنيميشن | التقنية | التوقيت |
|---|---|---|
| Button shrink | `active:scale-95 transition-transform duration-120` | 120ms |
| Screen fade+slide | `motion/react` AnimatePresence | 300ms |
| Count-up counter | custom hook يزيد الرقم تدريجياً | 700ms |
| Checkmark success | scale 0→1 + opacity | 300ms |
| Staggered cards | `motion/react` stagger 0.08s | 300ms each |
| Shimmer skeleton | CSS `@keyframes shimmer` | 1.5s infinite |
| Chart growth | Recharts built-in animation | 800ms |
| Splash pulse dots | CSS `@keyframes pulse` opacity+scale | 1.2s infinite |
| Electricity warning | CSS `@keyframes pulse` border | 900ms |
| Circular energy meter | CSS `stroke-dashoffset` transition | 700ms |

---

## 8. تحديث theme.css و fonts.css

### fonts.css
```css
@import url('https://fonts.googleapis.com/css2?family=Cairo:wght@400;500&display=swap');
```

### theme.css — تحديث القيم (الهيكل يبقى كما هو):
- `--background: #F7F4EE`
- `--foreground: #2E2C28`
- `--primary: #6B8E6B`
- `--secondary: #C97B4A`
- `--card: #FFFFFF`
- `--border: #D3D1C7`
- `--destructive: #B8503F`
- إضافة custom properties: `--surface`, `--text-secondary`, `--danger-bg`, `--secondary-foreground`
- Dark mode: جميع القيم المقابلة كما في وثيقة التصميم

---

## 9. البيانات الوهمية (mockData.ts)

```typescript
// معاملات تجريبية لآخر 3 أشهر
transactions: [
  { id, type: 'expense'|'income', amount, categoryId, productId?, date, note? }
]
// تصنيفات
categories: [
  { id, name, icon, type: 'expense'|'income'|'both' }
]
// قراءات الكهرباء
readings: [
  { id, value, date, consumption, cost }
]
```

---

## 10. ترتيب التنفيذ

1. **fonts.css + theme.css** — تحديث الألوان والخط
2. **mockData.ts + useAppStore.ts** — البيانات والحالة
3. **المكوّنات المشتركة** — كل الـ widgets في `components/`
4. **SplashScreen** — مع أنيميشن النقاط والانتقال
5. **HomeScreen** — Dashboard كامل مع 3 حالات
6. **Add Expense + Add Income** — مع validation
7. **TransactionsScreen + TransactionDetail**
8. **StatisticsScreen** — Recharts charts
9. **ElectricityHomeScreen + AddReading + ReadingLog**
10. **CategoriesScreen + ProductsScreen**
11. **SettingsScreen** — Dark mode toggle
12. **App.tsx** — Router + BottomNav + انتقالات الشاشات

---

## 11. التحقق من الصحة

- تشغيل `npm run dev` والتحقق من شاشة Splash تظهر ثم تنتقل للـ Home
- التحقق من Dark mode يعمل ويطبق الألوان الصحيحة
- إضافة مصروف ودخل والتحقق من ظهورهما في الـ Dashboard وسجل المعاملات
- التحقق من الرسوم البيانية تظهر في Statistics
- التحقق من RTL صحيح في جميع الشاشات
- التحقق من الـ shimmer loading يظهر ويختفي
- اختبار الحالات الفارغة بحذف جميع البيانات الوهمية
