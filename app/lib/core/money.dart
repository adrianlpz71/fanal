import 'package:decimal/decimal.dart';

/// Formateo de dinero es-ES SIN pasar por double: `1.234,56 €`. Los negativos llevan el signo
/// menos tipográfico (`−12,50 €`, U+2212), igual en importes, porcentajes y ejes.
///
/// No se usa `NumberFormat.currency('es_ES')` porque CLDR para español no agrupa los
/// números de 4 cifras (daría `1234,56 €`), y aquí se quiere siempre el punto de miles.
/// Modo privacidad (lo gestiona `core/privacy.dart`): los importes se muestran como "•••• €".
bool privacyMode = false;

String formatEur(Decimal amount, {bool showPlus = false, int decimals = 2}) {
  if (privacyMode) return '••••$nbsp€';
  final abs = amount < Decimal.zero ? -amount : amount;
  final fixed = abs.toStringAsFixed(decimals); // redondeo half-up de Decimal
  // El signo se decide DESPUÉS de redondear: -0,004 € se muestra "0,00 €", no "-0,00 €".
  final negative = amount < Decimal.zero && Decimal.parse(fixed) != Decimal.zero;
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  final sign = negative ? minus : (showPlus && amount > Decimal.zero ? '+' : '');
  final dec = decimals > 0 ? ',${parts[1]}' : '';
  return '$sign$buf$dec$nbsp€';
}

/// Espacio entre la cifra y "€" (o "%", "part."): no separable, para que nunca quede "€" solo
/// en la línea siguiente.
const nbsp = ' ';

/// Signo menos de toda la app (el guion corto se ve más pequeño que el "+").
const minus = '−';

/// Cambia el guion de un número ya formateado por el signo menos.
String withMinus(String s) => s.replaceAll('-', minus);

/// Parsea importes escritos a la española (`1.234,56`, `-12,5`, `12`) o con punto decimal
/// cuando no hay ambigüedad (`12.50`). Devuelve null si no es un número válido.
Decimal? parseEsDecimal(String input) {
  var s = input.trim().replaceAll(' ', '').replaceAll(nbsp, '').replaceAll('€', '').replaceAll('−', '-');
  if (s.isEmpty) return null;
  if (s.contains(',')) {
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else if (RegExp(r'^-?\d{1,3}(\.\d{3})+$').hasMatch(s)) {
    s = s.replaceAll('.', ''); // "1.234" = mil doscientos treinta y cuatro
  }
  return Decimal.tryParse(s);
}

/// Los importes llegan de la API como string decimal ("1234.56"). Nunca double.
Decimal dec(String? s) => s == null || s.isEmpty ? Decimal.zero : Decimal.parse(s);

/// Formatea un importe de la API (string) como "1.234,56 €".
String eur(String? s, {bool plus = false}) => formatEur(dec(s), showPlus: plus);

/// Decimal → string para enviar a la API.
String apiAmount(Decimal d) => d.toStringAsFixed(2);

/// Etiqueta de eje con importes: "12000" o, con [thousands], "15k". En modo privacidad, "•••":
/// las gráficas no pueden enseñar lo que ocultan los importes.
String axisAmount(double v, {bool thousands = false}) {
  if (privacyMode) return '•••';
  return thousands ? '${(v / 1000).round()}k' : '${v.round()}';
}
