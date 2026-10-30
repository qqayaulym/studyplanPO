# StudyPlan — Практикалық жұмыс №4 (Hive дерекқоры)

> Жоба Flutter-де жазылды, бірақ мен оны компиляциялап іске қоса алмадым (менің ортамда Flutter SDK жоқ).
> Сондықтан төмендегі `flutter analyze` және `flutter test` командаларын міндетті түрде өз компьютеріңде орындап көр.
> Қате шықса — қатенің мәтінін маған жібер, түзетемін.

---------------------------------------------------------------------

## 1. Қалай қосу керек (Windows 10, VS Code)

Бұл архивте **жобаның толық нұсқасы** бар (ПЖ №3 + дерекқор). Ең оңай жол:

1. Архивті ашып, `studyplan` папкасын жаңа жерге шығар (мысалы `D:\projects\studyplan_v4`).
2. Папканың ішінде **терминал** ашып, платформа файлдарын құр (папкада `android/`, `web/`, `windows/` әлі жоқ):
   ```
   flutter create --project-name studyplan .
   ```
   Сұрақ шықса — жауап берме, ол `lib/`, `test/`, `pubspec.yaml` файлдарыңды **өшірмейді**
   (өшіріп кетсе, архивтен қайта көшір). Бұдан кейін `test/widget_test.dart` архивтегімен ауысқанын тексер.
3. Пакеттерді жүкте:
   ```
   flutter pub get
   ```
   (`pubspec.yaml`-да `hive`, `hive_flutter`, `crypto` бар.)
4. Тексеру:
   ```
   flutter analyze
   flutter test
   ```
5. Іске қосу:
   ```
   flutter run -d web-server --web-port=5000
   ```
   Содан кейін **Edge-те** `http://localhost:5000` ашасың.

### Неге `-d edge` емес?
`flutter run -d edge` браузерді **уақытша профильмен** ашады, жабылғанда барлық сақталған деректер
(IndexedDB) өшеді. Ал №20-тапсырма — «қайта іске қосқаннан кейін деректер сақталды ма» — дәл осыны тексереді.
Сондықтан:
* веб үшін — `web-server` + тұрақты порт `5000` + әдеттегі Edge (жоғарыда);
* немесе Android эмулятор / телефон (`flutter run`), немесе Windows desktop (`flutter run -d windows`, Visual Studio-да
  "Desktop development with C++" керек).

### Өз экрандарың болса (ПЖ №3-ті өзің жасаған болсаң)
Мен сенің экрандарыңды көрмеймін, сондықтан толық жобаны бердім. Өз жобаңа көшіргің келсе:
1. `lib/core/database/`, `lib/core/utils/{id_gen,password_hasher,app_messenger}.dart` көшір.
2. Модельдер: `features/*/domain/*.dart` (`app_user`, `subject`, `task`, `subtask`).
3. Repository: `task_repository`, `subtask_repository`, `subject_repository`, `auth_service`, `app_settings`.
4. `main.dart`-тағы `bootstrap()` және `MaterialApp(scaffoldMessengerKey: AppMessenger.key)`.
5. Экрандарда деректі тек repository арқылы ал: `TaskRepository.instance.query(...)`, `.create(...)`, `.update(...)`, `.remove(...)`,
   `.toggleFavorite(...)`. Жазу әдістері `Future<bool>` қайтарады — `await` ет.
Сілтеме үшін менің экрандарым архивте бар (`features/tasks/presentation/*`).

---------------------------------------------------------------------

## 2. Жоба құрылымы (ПЖ №4-те қосылғаны)

```
lib/
├─ core/database/app_database.dart     ← Hive инициализациясы, қораптар, seed, қате өңдеу
├─ features/
│  ├─ auth/domain/app_user.dart        ← Entity: User
│  ├─ subjects/domain/subject.dart     ← Entity: Subject
│  ├─ subjects/data/subject_repository.dart
│  ├─ subjects/presentation/subjects_screen.dart  ← пәндер CRUD экраны
│  ├─ tasks/domain/task.dart           ← Entity: Task
│  ├─ tasks/domain/subtask.dart        ← Entity: SubTask
│  ├─ tasks/data/task_repository.dart  ← Repository: CRUD + іздеу + сүзгі + сұрыптау + favorites
│  ├─ tasks/data/subtask_repository.dart
│  ├─ auth/data/auth_service.dart      ← тіркелу/кіру, сессияны сақтау
│  └─ settings/app_settings.dart       ← параметрлер дерекқорда
└─ main.dart                            ← bootstrap(): DB ашу → параметрлер → сессия
docs/er_diagram.png                     ← ER-диаграмма
test/                                   ← автотесттер
```

---------------------------------------------------------------------

## 3. 20 қадамның орындалуы (тапсыру кестесі)

| № | Тапсырма | Қайда / қалай орындалды |
|---|----------|--------------------------|
| 1 | Ақпарат түрлері | Пайдаланушылар, пәндер, тапсырмалар, тапсырма қадамдары, параметрлер (тақырып, еске салғыш), соңғы іздеулер |
| 2 | 4–6 модель | `AppUser`, `Subject`, `Task`, `SubTask` (4 Entity) |
| 3 | Өрістер, типтер, ID | `docs/er_diagram.png`; барлығында `id: String` (уақыт белгісі + есептегіш, `IdGen.next()`) |
| 4 | Байланыстар | User 1—N Task (`userId`), Subject 1—N Task (`subjectId`), Task 1—N SubTask (`taskId`) |
| 5 | SQLite/Hive таңдау | **Hive** — Dart-та жазылған, web/Windows/Android-та бірдей істейді, native баптау қажет емес (sqflite веб-те істемейді) |
| 6 | Орнату | `pubspec.yaml`: `hive`, `hive_flutter`, `crypto`; `flutter pub get` |
| 7 | Инициализация | `AppDatabase.init()` → `Hive.initFlutter()`, 5 қорап ашылады, бірінші іске қосуда seed |
| 8 | Create | `TaskRepository.create`, `SubTaskRepository.add`, `SubjectRepository.add`, `AuthService.register` |
| 9 | Read | `TaskRepository.all/byId/query`; тізім, басты бет, мәлімет, іздеу, таңдаулы, статистика экрандары |
| 10 | Update | `TaskRepository.update/toggleDone/toggleFavorite`, `SubjectRepository.rename`, `AuthService.updateName` |
| 11 | Delete | `TaskRepository.remove` (қадамдарымен бірге — cascade), `SubTaskRepository.remove`, `SubjectRepository.remove` |
| 12 | Repository/Service | `features/*/data/*` — экрандар Hive-пен тікелей жұмыс істемейді |
| 13 | Іздеу | `query(text: ...)` — атауы, сипаттамасы, пән атауы бойынша; «Іздеу» экраны |
| 14 | Сүзгілеу | Пән, мәртебе (белсенді/орындалды/кешікті), «тек таңдаулылар» — «Тапсырмалар» экраны |
| 15 | Сұрыптау | 3 параметр: мерзімі, атауы, қосылған күні + өсу/кему (`showSortSheet`) |
| 16 | Favorites | `Task.isFavorite` дерекқорда; ★ батырмасы, «Таңдаулы» бөлімі |
| 17 | Деректер жоқ | `EmptyState`: тапсырма жоқ, таңдаулы жоқ, ештеңе табылмады, сүзгі нәтижесіз, пән/қадам жоқ |
| 18 | Қателерді өңдеу | `DbException`, `AppDatabase.run()` (try/catch → SnackBar), ашылмаса `DbErrorApp` + «Қайталау»; жазу сәтсіз болса форма ашық қалады |
| 19 | Интернетсіз | Қосымша ешбір желі сұрауын жібермейді, барлығы жергілікті Hive-та. Тексеру: Wi‑Fi өшір → CRUD |
| 20 | Қайта іске қосу | Деректер + сессия + параметрлер сақталады; автотест: `test/repository_test.dart` («қайта іске қосқаннан кейін сақталады») |

---------------------------------------------------------------------

## 4. Қолмен тексеру кестесі (скриншот жасап, құжатқа қой)

Демо аккаунт: `aidana@mail.kz` / `12345678`

| № | Әрекет | Күтілетін нәтиже | Орындалды |
|---|--------|-------------------|-----------|
| 1 | Кіру | Басты бет ашылады, 6 тапсырма бар | ☐ |
| 2 | «+» → атау, пән, мерзім → Сақтау | Тапсырма тізімде пайда болады | ☐ |
| 3 | Атауын бос қалдырып сақтау | «Тапсырма атауын енгізіңіз» | ☐ |
| 4 | Тапсырма → Өңдеу → атауын өзгерту | Өзгеріс көрінеді | ☐ |
| 5 | Тапсырма → Жою → растау | Тізімнен жоғалады | ☐ |
| 6 | Детальда қадам қосу, белгілеу, өшіру | Есептегіш `1 / 3` өзгереді | ☐ |
| 7 | Іздеу: «sql» | 1 нәтиже | ☐ |
| 8 | Іздеу: «абвгдеж123» | «Ештеңе табылмады» | ☐ |
| 9 | Тізім → пән чипін басу | Тек сол пән көрінеді | ☐ |
| 10 | Сұрыптау → «Атауы бойынша» / «Кему ретімен» | Реті өзгереді | ☐ |
| 11 | ★ басу → «Таңдаулы» бөлімі | Тапсырма сонда көрінеді | ☐ |
| 12 | Жаңа аккаунт тіркеу | Тізім бос: «Әзірге тапсырма жоқ» | ☐ |
| 13 | Wi‑Fi өшіру → 2–10 қайталау | Бәрі істейді | ☐ |
| 14 | Қосымшаны жауып қайта ашу | Деректер, қараңғы режим, сессия сақталған | ☐ |
| 15 | Профиль → Пәндер → тапсырмасы бар пәнді жою | «Бұл пәнде тапсырмалар бар…» | ☐ |

---------------------------------------------------------------------

## 5. Қорғауда сұрақтарға жауап

* **Неге Hive?** Таза Dart, жылдам, схема/миграция қажет емес, бір кодпен web, Windows, Android-та істейді. SQLite (`sqflite`) веб-те істемейді, ал мен Edge-те тексеремін.
* **Hive-та кесте жоқ, байланыс қалай?** Әр Entity — бөлек қорап (`Box`); байланыс — `userId`, `subjectId`, `taskId` сыртқы кілттері арқылы; JOIN орнына repository-де сүзгі.
* **Неге Map сақтаймыз, адаптер емес?** `build_runner` керек емес, код қарапайым: `toMap()` / `fromMap()`.
* **Repository не үшін?** UI дерекқорды білмейді: ертең Hive-ты SQLite-қа/Firebase-ке ауыстырсақ, экрандар өзгермейді.
* **Құпиясөз қалай сақталады?** Ашық емес — SHA-256 хэші (`PasswordHasher`). Нақты жобада bcrypt/Firebase Auth қолданған дұрыс.
* **Қате болса не болады?** Жазу `AppDatabase.run()` ішінде: try/catch → SnackBar; сәтсіз болса кэш өзгермейді, форма ашық қалады.
* **Қайта іске қосқанда неге сақталады?** Hive деректерді файлға (web-те IndexedDB-ға) жазады, іске қосылғанда `bootstrap()` қайта оқиды.
* **Cascade деген не?** Тапсырма жойылғанда оның қадамдары да жойылады (`removeForTask`), «жетім» жазбалар қалмайды.
