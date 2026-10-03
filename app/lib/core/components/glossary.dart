/// Glosario único de Faro: cada término técnico se explica aquí y solo aquí (lo usan `InfoTip` y
/// las ⓘ de los KPI). Lenguaje claro, dos o tres frases como mucho, sin consejo financiero.
class GlossaryEntry {
  const GlossaryEntry(this.term, this.text);
  final String term;
  final String text;
}

const glossary = <String, GlossaryEntry>{
  'twr': GlossaryEntry(
    'TWR (rentabilidad de la cartera)',
    'Lo que han hecho tus inversiones sin contar cuándo ni cuánto aportas. Sirve para compararte con '
        'un fondo o un índice.',
  ),
  'xirr': GlossaryEntry(
    'XIRR (tu rentabilidad anual)',
    'Tu rentabilidad real al año teniendo en cuenta cuándo pusiste cada euro. Es la que mide cómo le '
        'ha ido a tu dinero.',
  ),
  'pmp': GlossaryEntry(
    'PMP (precio medio de compra)',
    'Lo que te ha costado de media cada participación, contando todas tus compras.',
  ),
  'vl': GlossaryEntry(
    'VL (valor liquidativo)',
    'El precio de una participación de un fondo en un día. Se conoce al cierre, por eso una compra '
        'queda "pendiente de VL" hasta entonces.',
  ),
  'fifo': GlossaryEntry(
    'FIFO',
    'Al vender, Hacienda considera que vendes primero las participaciones más antiguas. Así se '
        'calcula la ganancia que declaras.',
  ),
  'coast': GlossaryEntry(
    'Coast FIRE',
    'El capital que, sin aportar ni un euro más, llegaría solo a lo que necesitas a tu edad '
        'objetivo con la rentabilidad supuesta.',
  ),
  'swr': GlossaryEntry(
    'Tasa de retiro',
    'Qué parte del capital retiras cada año para vivir. Con un 4 %, 1.000.000 € dan 40.000 € al '
        'año. Cuanto más baja, más tiempo dura el dinero.',
  ),
  'real': GlossaryEntry(
    'Rentabilidad real',
    'La rentabilidad después de restar la inflación y los costes: lo que crece tu poder de compra.',
  ),
  'drawdown': GlossaryEntry(
    'Máxima caída',
    'La mayor bajada desde un máximo hasta el mínimo siguiente. Da una idea de cuánto puede '
        'llegar a caer la cartera.',
  ),
  'volatility': GlossaryEntry(
    'Volatilidad',
    'Cuánto se mueve la rentabilidad de un mes a otro, pasada a un año. Más volatilidad, más '
        'sustos por el camino.',
  ),
  'base-ahorro': GlossaryEntry(
    'Base del ahorro',
    'Ganancias por vender inversiones, intereses y dividendos. Tributa con su propia escala, '
        'distinta de la del sueldo.',
  ),
  'base-general': GlossaryEntry(
    'Base general',
    'Sobre todo el sueldo (menos gastos deducibles como la Seguridad Social). Tributa con la escala '
        'estatal y la de tu comunidad.',
  ),
  'minimo-personal': GlossaryEntry(
    'Mínimo personal',
    'Una parte de tu renta que no paga impuestos porque se considera necesaria para vivir.',
  ),
  'tolerancia': GlossaryEntry(
    'Tolerancia (pp)',
    'Cuántos puntos porcentuales se puede alejar un activo de su objetivo dentro de su categoría '
        'antes de considerarse fuera.',
  ),
  'watchlist': GlossaryEntry(
    'Watchlist',
    'Activos que sigues sin tenerlos ni tener un objetivo para ellos. No cuentan en la cartera.',
  ),
  'proyeccion-hito': GlossaryEntry(
    'Al ritmo actual',
    'Proyección con tu aportación media de los últimos 12 meses (inversión y ahorro), sin contar '
        'rentabilidad. No es una previsión ni un consejo.',
  ),
  'tras-impuestos': GlossaryEntry(
    'Si vendieras hoy',
    'Patrimonio menos el impuesto que pagarías por la ganancia latente si vendieras todo hoy '
        '(FIFO y escala del ahorro del año). Es una estimación.',
  ),
};
