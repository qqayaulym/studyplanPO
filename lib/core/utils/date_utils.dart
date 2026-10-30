const List<String> _months = [
  'қаңтар',
  'ақпан',
  'наурыз',
  'сәуір',
  'мамыр',
  'маусым',
  'шілде',
  'тамыз',
  'қыркүйек',
  'қазан',
  'қараша',
  'желтоқсан',
];

const List<String> weekdayShort = ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сн', 'Жс'];

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// ДД.АА.ЖЖЖЖ
String formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d.$m.${date.year}';
}

/// «19 қазан»
String formatDayMonth(DateTime date) => '${date.day} ${_months[date.month - 1]}';

/// Мерзімге дейін қанша күн қалғанын қазақша сипаттайды.
String daysLeftText(DateTime deadline, {DateTime? now}) {
  final diff = dateOnly(deadline).difference(dateOnly(now ?? DateTime.now())).inDays;
  if (diff < 0) return 'Мерзімі өтті';
  if (diff == 0) return 'Бүгін';
  if (diff == 1) return 'Ертең';
  return '$diff күннен кейін';
}
