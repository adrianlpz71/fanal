import 'package:flutter/material.dart';

/// Tokens de diseño de Faro: espaciado, radios, anchos y puntos de corte. Todo lo visual de la app
/// sale de aquí y de `theme.dart`; las pantallas no llevan números sueltos.
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

abstract final class Radii {
  static const sm = 8.0; // chips, campos
  static const md = 12.0; // tarjetas
  static const lg = 16.0; // hojas y diálogos
}

/// Tamaño de la ventana (Material 3 + uno grande para monitores de 1.440 px o más).
enum SizeClass { compact, medium, expanded, large }

abstract final class Breakpoints {
  static const medium = 600.0;
  static const expanded = 1024.0;
  static const large = 1440.0;

  /// Con el texto del sistema grande, la distribución se elige con el ancho "en letras": a 820 px
  /// y 130 % de texto caben las mismas palabras que en 630 px, así que se usa la de ese ancho.
  static double effective(double width, double textScale) => width / (textScale < 1 ? 1 : textScale);

  static SizeClass of(double width) => width < medium
      ? SizeClass.compact
      : width < expanded
          ? SizeClass.medium
          : width < large
              ? SizeClass.expanded
              : SizeClass.large;
}

abstract final class FaroLayout {
  /// Ancho máximo del contenido: dashboards hasta 1.280 px (1.440 en pantallas grandes).
  static double maxWidth(double windowWidth) => windowWidth >= Breakpoints.large ? 1440 : 1280;

  /// Ancho legible para listas y formularios de página.
  static const readable = 760.0;

  /// Pantallas aún no rediseñadas: la columna de siempre (se irá quitando fase a fase).
  static const legacy = 1040.0;

  /// Diálogos de formulario.
  static const formPanel = 560.0;

  /// Panel lateral (resumen o detalle junto a una lista).
  static const sidePanel = 400.0;

  /// Margen lateral del contenido.
  static double gutter(SizeClass s) => s == SizeClass.compact ? Space.lg : Space.xl;
}

extension SizeClassX on BuildContext {
  SizeClass get sizeClass =>
      Breakpoints.of(Breakpoints.effective(MediaQuery.sizeOf(this).width, MediaQuery.textScalerOf(this).scale(1)));
  bool get isCompact => sizeClass == SizeClass.compact;
  bool get isWide => sizeClass.index >= SizeClass.expanded.index;
}

/// Colores con significado (ganancia, pérdida, aviso, información) y la paleta de series. Se
/// definen para claro y oscuro con contraste AA sobre la superficie, y siempre van con icono.
@immutable
class FaroColors extends ThemeExtension<FaroColors> {
  const FaroColors({
    required this.gain,
    required this.loss,
    required this.warning,
    required this.info,
    required this.gainContainer,
    required this.lossContainer,
    required this.warningContainer,
    required this.infoContainer,
    required this.series,
  });

  final Color gain, loss, warning, info;
  final Color gainContainer, lossContainer, warningContainer, infoContainer;
  final List<Color> series;

  static const light = FaroColors(
    gain: Color(0xFF1B7A3A),
    loss: Color(0xFFC0262D),
    warning: Color(0xFF8F5300),
    info: Color(0xFF0B63A0),
    gainContainer: Color(0xFFD7F2DF),
    lossContainer: Color(0xFFFBDDDD),
    warningContainer: Color(0xFFFCE8C8),
    infoContainer: Color(0xFFD6E9F8),
    series: _series,
  );

  static const dark = FaroColors(
    gain: Color(0xFF5ED38C),
    loss: Color(0xFFFF8E86),
    warning: Color(0xFFFFB95C),
    info: Color(0xFF82C6FF),
    gainContainer: Color(0xFF173A25),
    lossContainer: Color(0xFF4A1D1E),
    warningContainer: Color(0xFF45300F),
    infoContainer: Color(0xFF13324A),
    series: _series,
  );

  /// Gris medio para lo que no tiene color propio (una categoría sin color): se ve en los dos temas.
  static const neutral = Color(0xFF9E9E9E);

  /// Diez colores de luminosidad media: se distinguen entre sí en los dos temas.
  static const _series = [
    Color(0xFF2BA89A), // verde azulado
    Color(0xFF5B8DEF), // azul
    Color(0xFFE9A23B), // ámbar
    Color(0xFFA47CF0), // violeta
    Color(0xFFE8709A), // rosa
    Color(0xFF6DB86B), // verde
    Color(0xFFF08A4B), // naranja
    Color(0xFF45BFD3), // cian
    Color(0xFFB7B33A), // oliva
    Color(0xFFB08A78), // marrón
  ];

  /// Color fijo de una serie (activo, cuenta…): el mismo id da siempre el mismo color, en todas
  /// las gráficas, leyendas y tarjetas.
  Color seriesFor(String id) {
    var h = 0;
    for (final c in id.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return series[h % series.length];
  }

  /// Colores para varias series que se ven juntas (un donut, una gráfica apilada): el de
  /// [seriesFor] si está libre y, si dos chocan, el siguiente libre de la paleta. Con los mismos
  /// ids en el mismo orden sale siempre lo mismo.
  Map<String, Color> seriesForAll(Iterable<String> ids) {
    final out = <String, Color>{};
    final used = <int>{};
    for (final id in ids) {
      var i = series.indexOf(seriesFor(id));
      for (var k = 0; k < series.length && used.contains(i); k++) {
        i = (i + 1) % series.length;
      }
      used.add(i);
      out[id] = series[i];
    }
    return out;
  }

  @override
  FaroColors copyWith({Color? gain, Color? loss, Color? warning, Color? info}) => FaroColors(
        gain: gain ?? this.gain,
        loss: loss ?? this.loss,
        warning: warning ?? this.warning,
        info: info ?? this.info,
        gainContainer: gainContainer,
        lossContainer: lossContainer,
        warningContainer: warningContainer,
        infoContainer: infoContainer,
        series: series,
      );

  @override
  FaroColors lerp(FaroColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return FaroColors(
      gain: l(gain, other.gain),
      loss: l(loss, other.loss),
      warning: l(warning, other.warning),
      info: l(info, other.info),
      gainContainer: l(gainContainer, other.gainContainer),
      lossContainer: l(lossContainer, other.lossContainer),
      warningContainer: l(warningContainer, other.warningContainer),
      infoContainer: l(infoContainer, other.infoContainer),
      series: t < 0.5 ? series : other.series,
    );
  }
}

extension FaroColorsX on BuildContext {
  FaroColors get faro =>
      Theme.of(this).extension<FaroColors>() ??
      (Theme.of(this).brightness == Brightness.dark ? FaroColors.dark : FaroColors.light);
}

/// Estilos de texto propios (además de los de Material 3).
abstract final class FaroText {
  static const tabular = [FontFeature.tabularFigures()];

  /// Cifra grande de un KPI.
  static TextStyle kpi(BuildContext context) => Theme.of(context).textTheme.headlineSmall!.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: tabular,
      );

  /// Importe en listas y tablas.
  static TextStyle amount(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600, fontFeatures: tabular);

  /// Cabecera de sección ("PENDIENTES · 8").
  static TextStyle overline(BuildContext context) => Theme.of(context).textTheme.labelMedium!.copyWith(
        letterSpacing: 0.8,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  /// Texto secundario.
  static TextStyle caption(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );
}
