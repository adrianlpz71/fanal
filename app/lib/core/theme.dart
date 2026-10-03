import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tema de Faro: azul petróleo sobrio, oscuro por defecto. Verde y rojo, solo para ganancias y
/// pérdidas (`context.faro`). Superficies planas con borde: la jerarquía la dan el tamaño y el
/// espacio, no las sombras.
class FaroTheme {
  static const seed = Color(0xFF0E5E6F);

  /// Ancho de las pantallas aún no rediseñadas (ver `FaroLayout`).
  static const contentMaxWidth = FaroLayout.legacy;

  /// Separación vertical entre campos de un formulario (ver `FormListView` y `core/forms`).
  static const fieldGap = 20.0;

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness b) {
    final cs = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    final dark = b == Brightness.dark;
    return ThemeData(
      colorScheme: cs,
      useMaterial3: true,
      scaffoldBackgroundColor: cs.surface,
      extensions: [dark ? FaroColors.dark : FaroColors.light],
      // Campos: etiqueta siempre visible en el borde (y por tanto también la unidad, € o %),
      // legible, y la ayuda en dos líneas como mucho. Igual en toda la app.
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(Radii.sm)),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: const TextStyle(fontSize: 16),
        floatingLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        helperMaxLines: 6, // las ayudas no se cortan (nada con "…")
        errorMaxLines: 6,
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.md),
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: dark ? 0.6 : 0.8)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.lg)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg))),
      ),
      chipTheme: ChipThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sm))),
      // Importes a la derecha de las filas: el estilo de las cifras de toda la app (M3 los pondría en
      // letra pequeña), tabulares y que crecen con el texto del sistema
      listTileTheme: ListTileThemeData(
        leadingAndTrailingTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFeatures: FaroText.tabular,
          color: cs.onSurface,
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant.withValues(alpha: 0.6), space: 1),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 400)),
    );
  }
}
