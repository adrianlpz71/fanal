/// Fechas en español de España, sin depender de los datos de `intl` (que pone punto en las
/// abreviaturas y varía según la versión).
const monthsShortEs = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
const weekdaysShortEs = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// "2 oct 2026".
String fullDate(DateTime d) => '${d.day} ${monthsShortEs[d.month - 1]} ${d.year}';

/// "2 oct" (sin año).
String dayMonth(DateTime d) => '${d.day} ${monthsShortEs[d.month - 1]}';

/// "oct 26".
String monthYear(DateTime d) => '${monthsShortEs[d.month - 1]} ${d.year % 100}';

/// Solo el día (sin hora) en UTC, como lo espera la API.
DateTime apiDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);
