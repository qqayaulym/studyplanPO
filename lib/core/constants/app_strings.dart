/// Қосымшадағы барлық мәтіндер бір жерде (қазақ тілі).
class AppStrings {
  AppStrings._();

  static const String appName = 'StudyPlan';
  static const String tagline = 'Оқу тапсырмаларың — бір жерде';

  // Жалпы
  static const String save = 'Сақтау';
  static const String cancel = 'Болдырмау';
  static const String delete = 'Жою';
  static const String edit = 'Өңдеу';
  static const String back = 'Артқа';
  static const String all = 'Барлығы';
  static const String close = 'Жабу';

  // Onboarding
  static const String next = 'Келесі';
  static const String start = 'Бастау';
  static const String skip = 'Өткізіп жіберу';
  static const String onb1Title = 'Барлық тапсырма — бір жерде';
  static const String onb1Text =
      'Мессенджерлер мен дәптерде шашылған мерзімдерді бір тізімге жинаңыз.';
  static const String onb2Title = 'Мерзімді ұмытпаңыз';
  static const String onb2Text =
      'Тапсырма алдында еске салғыш келеді — кешікпей тапсырасыз.';
  static const String onb3Title = 'Прогресіңізді көріңіз';
  static const String onb3Text =
      'Қанша тапсырма орындалғанын пән бойынша бақылаңыз.';

  // Auth
  static const String welcomeBack = 'Қайта қош келдіңіз!';
  static const String loginSubtitle =
      'Тапсырмаларыңызды көру үшін жүйеге кіріңіз';
  static const String email = 'Электрондық пошта';
  static const String password = 'Құпиясөз';
  static const String fullName = 'Аты-жөні';
  static const String login = 'Кіру';
  static const String register = 'Тіркелу';
  static const String createAccount = 'Аккаунт жасау';
  static const String registerSubtitle = 'Бірнеше секундта тіркеліңіз';
  static const String forgotPassword = 'Құпиясөзді ұмыттыңыз ба?';
  static const String noAccount = 'Аккаунтыңыз жоқ па?';
  static const String haveAccount = 'Аккаунт бар ма?';
  static const String or = 'немесе';
  static const String googleLogin = 'Google арқылы кіру';
  static const String googleSoon = 'Google арқылы кіру кейінгі нұсқада қосылады';
  static const String resetTitle = 'Құпиясөзді қалпына келтіру';
  static const String resetText =
      'Email енгізіңіз — қалпына келтіру сілтемесін жібереміз.';
  static const String sendLink = 'Сілтеме жіберу';
  static const String linkSent = 'Қалпына келтіру сілтемесі жіберілді';
  static const String wrongCredentials = 'Email немесе құпиясөз дұрыс емес';
  static const String emailExists = 'Бұл email тіркелген';

  // Validation
  static const String enterEmail = 'Email енгізіңіз';
  static const String badEmail = 'Email форматын тексеріңіз';
  static const String enterPassword = 'Құпиясөзді енгізіңіз';
  static const String shortPassword = 'Құпиясөз кемінде 8 таңбадан тұруы керек';
  static const String enterName = 'Аты-жөніңізді енгізіңіз';
  static const String enterTitle = 'Тапсырма атауын енгізіңіз';
  static const String chooseSubject = 'Пәнді таңдаңыз';
  static const String chooseDate = 'Мерзімді таңдаңыз';
  static const String pastDate = 'Мерзімді болашақ күнге қойыңыз';

  // Navigation
  static const String navHome = 'Басты';
  static const String navTasks = 'Тапсырмалар';
  static const String navSearch = 'Іздеу';
  static const String navFavorites = 'Таңдаулы';
  static const String navProfile = 'Профиль';

  // Home
  static const String hello = 'Сәлем';
  static const String weekProgress = 'Жалпы прогресс';
  static const String upcoming = 'Жақын мерзімдер';
  static const String noTasks = 'Әзірге тапсырма жоқ';
  static const String reminders = 'Еске салғыштар';
  static const String noReminders = 'Жақын арада мерзімі бар тапсырма жоқ';

  // Tasks
  static const String tasks = 'Тапсырмалар';
  static const String tabAll = 'Барлығы';
  static const String tabActive = 'Белсенді';
  static const String tabDone = 'Орындалды';
  static const String addTask = 'Тапсырма қосу';
  static const String newTask = 'Жаңа тапсырма';
  static const String editTask = 'Тапсырманы өңдеу';
  static const String taskTitle = 'Тапсырма атауы';
  static const String subject = 'Пән';
  static const String deadline = 'Орындау мерзімі';
  static const String reminder = 'Еске салғыш';
  static const String description = 'Сипаттамасы (міндетті емес)';
  static const String addToFavorites = 'Таңдаулыға қосу';
  static const String markDone = 'Орындалды деп белгілеу';
  static const String markUndone = 'Орындалмады деп белгілеу';
  static const String deleteConfirmTitle = 'Тапсырманы жою керек пе?';
  static const String deleteConfirmText = 'Бұл әрекетті болдырмау мүмкін емес.';
  static const String taskAdded = 'Тапсырма қосылды';
  static const String taskUpdated = 'Өзгерістер сақталды';
  static const String taskDeleted = 'Тапсырма жойылды';
  static const String notFound = 'Тапсырма табылмады';
  static const List<String> reminderOptions = [
    'Еске салғышсыз',
    '1 сағат бұрын',
    '1 күн бұрын',
    '2 күн бұрын',
  ];

  // Search
  static const String searchHint = 'Тапсырмаларды іздеу';
  static const String results = 'Нәтижелер';
  static const String recent = 'Соңғы іздеулер';
  static const String nothingFound = 'Ештеңе табылмады';

  // Favorites
  static const String favorites = 'Таңдаулылар';
  static const String favoritesHint = 'Маңызды деп белгіленген тапсырмалар';
  static const String favoritesTip =
      'Тапсырма бетіндегі жұлдызшаны басып, таңдаулыға қосыңыз';

  // Profile
  static const String profile = 'Профиль';
  static const String editProfile = 'Профильді өзгерту';
  static const String statistics = 'Статистика';
  static const String settings = 'Параметрлер';
  static const String logout = 'Жүйеден шығу';
  static const String total = 'Барлығы';
  static const String done = 'Орындалды';
  static const String overdue = 'Кешікті';
  static const String profileUpdated = 'Профиль жаңартылды';

  // Settings
  static const String darkTheme = 'Қараңғы тақырып';
  static const String language = 'Тіл';
  static const String kazakh = 'Қазақша';
  static const String interfaceSection = 'ИНТЕРФЕЙС';
  static const String notificationsSection = 'ХАБАРЛАНДЫРУ';
  static const String otherSection = 'БАСҚА';
  static const String defaultTime = 'Әдепкі уақыт';
  static const String help = 'Көмек';
  static const String helpText =
      'StudyPlan — оқу тапсырмаларын жоспарлау қосымшасы.\n\n'
      '• «+» батырмасымен жаңа тапсырма қосыңыз.\n'
      '• Тапсырманы түртіп, толық мәліметін ашыңыз.\n'
      '• Жұлдызша арқылы маңызды тапсырманы таңдаулыға қосыңыз.\n'
      '• Статистика бөлімінде прогресіңізді көріңіз.';

  // Statistics
  static const String thisWeek = 'Осы аптадағы мерзімдер';
  static const String bySubject = 'Пәндер бойынша';

  // ---- ПЖ №4: дерекқор ----
  static const String noSubject = 'Пәнсіз';
  static const String allSubjects = 'Барлық пәндер';
  static const String sort = 'Сұрыптау';
  static const String sortDeadline = 'Мерзімі бойынша';
  static const String sortTitle = 'Атауы бойынша (А–Я)';
  static const String sortCreated = 'Қосылған күні бойынша';
  static const String ascending = 'Өсу ретімен';
  static const String descending = 'Кему ретімен';
  static const String tabOverdue = 'Кешікті';
  static const String onlyFavorites = 'Тек таңдаулылар';
  static const String subtasks = 'Қадамдар';
  static const String addSubtask = 'Қадам қосу';
  static const String subtaskHint = 'Жаңа қадам атауы';
  static const String noSubtasks = 'Қадамдар әлі жоқ';
  static const String subjectsTitle = 'Пәндер';
  static const String addSubject = 'Пән қосу';
  static const String renameSubject = 'Пәнді өзгерту';
  static const String subjectName = 'Пән атауы';
  static const String enterSubject = 'Пән атауын енгізіңіз';
  static const String subjectExists = 'Мұндай пән бар';
  static const String subjectInUse = 'Бұл пәнде тапсырмалар бар, алдымен оларды жойыңыз';
  static const String subjectDeleted = 'Пән жойылды';
  static const String subjectSaved = 'Пән сақталды';
  static const String noSubjects = 'Пәндер әлі жоқ';
  static const String emptyFavorites = 'Таңдаулы тапсырмалар жоқ';
  static const String emptySearch = 'Іздеу үшін сөз енгізіңіз';
  static const String clear = 'Тазалау';
  static const String dbOpenError = 'Дерекқорды ашу мүмкін болмады';
  static const String retry = 'Қайталау';
  static const String saveError = 'Деректі сақтау мүмкін болмады. Қайталап көріңіз';
  static const String readError = 'Деректі оқу мүмкін болмады';
  static const String deleteError = 'Жою мүмкін болмады. Қайталап көріңіз';
  static const String filterNothing = 'Таңдалған сүзгі бойынша тапсырма табылмады';
  static const String yourName = 'Аты-жөніңіз';
  static const String taskCount = 'тапсырма';
  static const String dueThisWeek = 'Жақын 7 күнде';
}
