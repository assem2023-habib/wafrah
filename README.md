# وِفرة (Wafrah)

> مصاريفك ودخلك بكل بساطة — تطبيق موبايل لإدارة المصاريف والدخل والكهرباء، مصمّم خصيصاً **لكبار السن**: خطوط كبيرة، تباين قوي، خطوات قليلة، وبلا ازدحام بصري.

تطبيق Flutter بواجهة عربية كاملة (RTL) يعمل على Android وiOS، يخزّن البيانات محلياً على الجهاز بلا حساب ولا إنترنت.

---

## المشكلة والحل

**المشكلة:** تطبيقات إدارة المصاريف الحالية مزدحمة، إنجليزية الواجهة غالباً، تتطلب تسجيل حساب واتصالاً دائماً، وتصعب على كبار السن بخطوط صغيرة وألوان متشابهة وقوائم عميقة. كما أن فاتورة الكهرباء السورية بشرائحها المتدرجة لا يفهمها أحد إلا بعد صدور الفاتورة.

**الحل الذي قدمته وِفرة:**
- واجهة عربية واحدة مبسطة بأزرار ≥48px وخط Cairo واضح وتباين Sage/Terracotta عالٍ.
- تخزين محلي بالكامل (Hive) — خصوصية تامة وعمل دون إنترنت.
- تسجيل أي عملية في ≤3 خطوات ظاهرة على نفس الشاشة.
- قسم كهرباء يحسب الاستهلاك والتكلفة المتوقعة من شرائح التعرفة التي يدخلها المستخدم بنفسه، مع تحذير بصري قبل تجاوز الحد.

## ماذا يقدم التطبيق؟

| المجال | الخدمة |
|---|---|
| المصاريف والدخل | تسجيل مصروف (بصنف ومنتج اختياري) ودخل، تعديل وحذف، بحث وفلاتر (نوع/صنف/منتج/فترة) |
| لوحة القيادة | الرصيد الكلي بعدّاد متحرك + إجمالي الدخل والمصاريف + آخر 5 حركات |
| الكهرباء | تسجيل قراءات العدّاد، حساب الاستهلاك والتكلفة حسب شرائح التعرفة القابلة للتخصيص، مقياس طاقة دائري بتحذير عند 80% من الحد |
| الإحصائيات | رسم دائري لتوزيع المصاريف ورسم مقارنة دخل/مصروف حسب اليوم/الأسبوع/الشهر |
| التخصيص | وضع ليلي/نهاري محفوظ + تقليل الحركة + إدارة أصناف ومنتجات |

---

## المعمارية (Architecture)

معمارية طبقية مع نمط MVVM عبر GetX:

```
┌─────────────────────────────────────────────┐
│  UI Layer      lib/modules/*/view.dart      │  عرض فقط، بلا منطق
├─────────────────────────────────────────────┤
│  Controllers   lib/modules/*/controller.dart │ حالة Rxx + منطق الشاشة
├─────────────────────────────────────────────┤
│  Interfaces    lib/data/repositories/interfaces/ │ عقود مجردة
├─────────────────────────────────────────────┤
│  Hive Impls    lib/data/repositories/hive/   │ تنفيذ فعلي فوق صناديق Hive
├─────────────────────────────────────────────┤
│  Models        lib/data/models/*.dart        │ HiveType مع مولدات .g.dart
└─────────────────────────────────────────────┘
        المشترك: lib/core/ (ألوان، مقاسات، نصوص، ثيم، أدوات)
                 lib/widgets/ (15 مكوّناً مشتركاً)
```

**قواعد ثابتة:** كل شاشة تستقبل تبعياتها حقناً عبر `Binding`، ولا تعرف شيئاً عن Hive؛ الألوان لا تُكتب hex داخل شاشات أبداً بل Tokens في `app_colors.dart`/الثيم؛ كل نص من `AppStrings.dart`.

شجرة المجلدات:

```
lib/
├── core/
│   ├── constants/    app_colors, app_dimens, app_strings, app_defaults
│   ├── theme/        app_theme, theme_service (حفظ الثيم), motion (تقليل الحركة)
│   └── utils/        number_formatter, validators, tariff_calculator
├── data/
│   ├── hive_service.dart          تهيئة الصناديق والبيانات الأولية
│   ├── models/                    Category, Product, Transaction,
│   │                              ElectricityReading, ElectricitySettings, AppSettings
│   └── repositories/
│       ├── interfaces/            4 واجهات مجردة
│       └── hive/                  التنفيذات الفعلية + repository_bindings
├── modules/           12 وحدة (كل واحدة: view + controller + binding)
├── routes/            app_routes (أسماء) + app_pages (خريطة GetX + RouteObserver)
└── widgets/           المكوّنات المشتركة (AppCard, AppNumberField, ...)
test/                  unit + widgets + feature (85 اختباراً)
DOCS/                  توثيق التصميم والمنطق الأصلي + النموذج المرجعي
readme/screens/        ملف تفصيلي لكل شاشة
```

## المنطق (Business Logic)

- **العملة:** ليرة سورية ثابتة؛ الأرقام بأرقام عربية؛ العملة تُختصر (1.2 مليون ل.س) بينما الكهرباء تبقى برقم كامل دقيق (315 ك.و).
- **منع الحذف:** لا يُحذف صنف/منتج له أي حركة مرتبطة، ولا صنف له منتجات — رسالة "يوجد بيانات سابقة مرتبطة" بلا استثناء.
- **شرائح التعرفة:** حدود تصاعدية صارمة؛ التكلفة = مجموع (ما ضمن كل شريحة × سعرها).
- **التواريخ:** بلا قيد على الماضي، ويُمنع تاريخ نهاية القراءة قبل بدايتها.
- **الفلاتر:** نوع + صنف + منتج + فترة زمنية قابلة للدمج كلها معاً.
- **التحقق الفوري:** أخطاء الحقول inline أسفل الحقل، والأخطاء المانعة ببانر `AppErrorBanner` لا يختفي تلقائياً.

التفاصيل الكاملة في [`DOCS/02-منطق-العمل.md`](DOCS/02-منطق-العمل.md).

## الميزات والحركات

كتالوج 10 حركات (عدّاد أرقام، ظهور متتالٍ staggered، شيمر تحميل، نمو الرسم الدائري، نبض تحذير...) كلها قابلة للتعطيل دفعة واحدة من مفتاح "تقليل الحركة". الوضع الليلي كامل ومحفوظ في Hive.

## المكاتب وسبب اختيارها

| المكتبة | السبب |
|---|---|
| [`get`](https://pub.dev/packages/get) | إدارة حالة + حقن تبعيات + توجيه بأسماء مع Bindings — يلغي الحاجة لـ Provider/Riverpod ويقلل Boilerplate، مناسب لحجم تطبيق متوسط |
| [`hive` + `hive_flutter`](https://pub.dev/packages/hive_flutter) | قاعدة بيانات NoSQL محلية سريعة بلا SQL ولا Native Dependencies معقدة، تدعم كائنات مخصصة بالـ TypeAdapters المولدة — مثالي للتخزين المحلي بلا خادم |
| [`intl`](https://pub.dev/packages/intl) | تنسيق التواريخ والأرقام بالعربية (`DateFormat('MMMM','ar')`) وتحويل الأرقام العربية — لا بديل موثوق لهذا الدور |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | الرسوم الدائرية والعمودية للإحصائيات بقابلة للتخصيص بألوان الثيم — الأكثر نضجاً بين مكتبات رسوم Flutter |
| [`flutter_tabler_icons`](https://pub.dev/packages/flutter_tabler_icons) | أيقونات Tabler الخطية النظيفة الملائمة للفئة العمرية المستهدفة (خط واحد، بلا تفاصيل) |
| [`path_provider`](https://pub.dev/packages/path_provider) | مسار تخزين Hive على كل منصة (متطلب لـ hive_flutter) |
| [`flutter_localizations`](https://docs.flutter.dev/) (SDK) | تعريب Material/Cupertino RTL + قاموس التواريخ العربي |

## التثبيت والتشغيل

المتطلبات: [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.x + جهاز أو محاكي.

```bash
# استنساخ
git clone https://github.com/assem2023-habib/wafrah.git
cd wafrah

# جلب الحزم
flutter pub get

# توليد ملفات Hive (.g.dart) — مضمّنة بالمستودع، أعد التوليد فقط بعد تعديل models
dart run build_runner build --delete-conflicting-outputs

# تشغيل
flutter run

# بناء APK
flutter build apk --release

# الاختبارات (85 اختباراً)
flutter test

# فحص التحليل
flutter analyze
```

---

## خريطة الشاشات — التوثيق التفصيلي

ملف مستقل لكل شاشة في [`readme/screens/`](readme/screens/) يشرح الغرض، الحالات الأربع، العناصر، الحركات، والمنطق:

| # | الشاشة | الملف | المسار |
|---|---|---|---|
| 1 | التحميل | [`01-splash.md`](readme/screens/01-splash.md) | `/splash` |
| 2 | الرئيسية | [`02-home.md`](readme/screens/02-home.md) | `/home` |
| 3 | إضافة مصروف | [`03-add-expense.md`](readme/screens/03-add-expense.md) | `/add-expense` |
| 4 | إضافة دخل | [`04-add-income.md`](readme/screens/04-add-income.md) | `/add-income` |
| 5 | سجل الحركات | [`05-transactions.md`](readme/screens/05-transactions.md) | `/transactions` |
| 6 | تفاصيل الحركة | [`06-transaction-detail.md`](readme/screens/06-transaction-detail.md) | `/transaction-detail` |
| 7 | إدارة الأصناف | [`07-categories.md`](readme/screens/07-categories.md) | `/categories` |
| 8 | إدارة المنتجات | [`08-products.md`](readme/screens/08-products.md) | `/products` |
| 9 | الإحصائيات | [`09-statistics.md`](readme/screens/09-statistics.md) | `/statistics` |
| 10 | الكهرباء - الرئيسية | [`10-electricity-home.md`](readme/screens/10-electricity-home.md) | `/electricity` |
| 11 | إضافة قراءة كهرباء | [`11-add-reading.md`](readme/screens/11-add-reading.md) | `/add-reading` |
| 12 | سجل قراءات الكهرباء | [`12-reading-log.md`](readme/screens/12-reading-log.md) | `/reading-log` |
| 13 | الإعدادات | [`13-settings.md`](readme/screens/13-settings.md) | `/settings` |

## التوثيق الأصلي (DOCS)

- [`01-التصميم-والشكل`](DOCS/01-التصميم-والشكل.md) — الهوية البصرية والألوان والحركات
- [`02-منطق-العمل`](DOCS/02-منطق-العمل.md) — نموذج البيانات والقواعد
- [`03-التقنيات`](DOCS/03-التقنيات.md) — حزمة التقنيات
- [`04-البنية-المعمارية`](DOCS/04-البنية-المعمارية.md) — الطبقات والمجلدات
- [`05-دليل-المكونات-المشتركة`](DOCS/05-دليل-المكونات-المشتركة.md) — مكوّنات widgets
- [`06-قيم-المقاسات`](DOCS/06-قيم-المقاسات.md) — Design Tokens الهندسية
- [`07-حالات-الشاشات`](DOCS/07-حالات-الشاشات.md) — حالات كل شاشة
- [`08-بيان-الأصول`](DOCS/08-بيان-الأصول.md) — الشعار والأصول
- [`Simple Phone App Screen/`](DOCS/Simple%20Phone%20App%20Screen/) — النموذج المرجعي التفاعلي (React)

## الحالة

- ✅ 11/12 شاشة مبنية ومراجعة ضد النموذج المرجعي
- 🚧 الإحصائيات: قيد التطوير (شاشة مؤقتة حالياً)
- الاختبارات: 85/85 ناجحة · `flutter analyze`: نظيف
