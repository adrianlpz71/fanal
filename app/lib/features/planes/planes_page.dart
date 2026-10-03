import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/widgets.dart';
import 'compare_page.dart';
import 'compound_tab.dart';
import 'data.dart';
import 'fire_form.dart';
import 'fire_tab.dart';
import 'goals_tab.dart';
import 'review_tab.dart';
import 'tax_tab.dart';

/// Planes: cada pestaña es una ruta (`/planes/independencia`, `/planes/objetivos`, …); las
/// pestañas las pone el shell. Orden: Independencia · Objetivos · Revisión · Interés compuesto ·
/// Impuestos (las calculadoras al final).
class PlanesPage extends StatelessWidget {
  const PlanesPage({super.key, this.tab = 'independencia'});
  final String tab;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const FaroAppBar(title: PageTitle('Planes')),
        body: switch (tab) {
          'objetivos' => const GoalsTab(),
          'revision' => const ReviewTab(),
          'interes-compuesto' => const CompoundTab(),
          'impuestos' => const TaxTab(),
          _ => const FireTab(),
        },
      );
}

/// Planes → Independencia → Supuestos (`/planes/independencia/supuestos`).
class FireAssumptionsPage extends ConsumerWidget {
  const FireAssumptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: const FaroAppBar(title: PageTitle('Supuestos')),
        body: ref.watch(fireSettingsProvider).when(
              loading: () => const SkeletonPage(),
              error: (e, _) => Center(child: Text(apiErrorMessage(e))),
              data: (st) => FireForm(settings: st, plan: ref.watch(firePlanProvider).value),
            ),
      );
}

/// Planes → Independencia → Comparar (`/planes/independencia/comparar`).
class FireComparePage extends ConsumerWidget {
  const FireComparePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(firePlanProvider).when(
        loading: () => const Scaffold(body: SkeletonPage()),
        error: (e, _) => Scaffold(body: Center(child: Text(apiErrorMessage(e)))),
        data: (f) => ComparePage(plan: f),
      );
}
