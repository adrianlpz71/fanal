import 'package:flutter/material.dart';

import '../../core/widgets.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            FaroLogo(size: 56),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ]),
        ),
      );
}
