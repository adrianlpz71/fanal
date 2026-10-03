import 'package:flutter/material.dart';

import '../tokens.dart';

/// Markdown sencillo para los textos editables (tutoriales en `assets/tutoriales/*.md`), sin un
/// paquete más: títulos (`#`, `##`), listas numeradas (`1.`) y con viñetas (`-`), párrafos y, en
/// línea, **negrita** y `código`. Lo que no entiende sale como texto normal.
class MarkdownLite extends StatelessWidget {
  const MarkdownLite(this.source, {super.key});
  final String source;

  static final _inline = RegExp(r'(\*\*[^*]+\*\*|`[^`]+`)');

  List<InlineSpan> _spans(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    final out = <InlineSpan>[];
    var last = 0;
    for (final m in _inline.allMatches(text)) {
      if (m.start > last) out.add(TextSpan(text: text.substring(last, m.start)));
      final t = m.group(0)!;
      if (t.startsWith('**')) {
        out.add(TextSpan(text: t.substring(2, t.length - 2), style: const TextStyle(fontWeight: FontWeight.w700)));
      } else {
        out.add(TextSpan(
          text: t.substring(1, t.length - 1),
          style: TextStyle(fontFamily: 'monospace', backgroundColor: cs.surfaceContainerHighest),
        ));
      }
      last = m.end;
    }
    if (last < text.length) out.add(TextSpan(text: text.substring(last)));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final blocks = <Widget>[];
    final para = <String>[];
    void flush() {
      if (para.isEmpty) return;
      blocks.add(Text.rich(TextSpan(children: _spans(context, para.join(' '))), style: tt.bodyMedium));
      para.clear();
    }

    Widget item(String marker, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 28, child: Text(marker, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
          Expanded(child: Text.rich(TextSpan(children: _spans(context, text)), style: tt.bodyMedium)),
        ]);

    for (final raw in source.split('\n')) {
      final line = raw.trimRight();
      final numbered = RegExp(r'^(\d+)\.\s+(.*)$').firstMatch(line.trimLeft());
      if (line.trim().isEmpty) {
        flush();
      } else if (line.startsWith('## ')) {
        flush();
        blocks.add(Padding(
          padding: const EdgeInsets.only(top: Space.sm),
          child: Text(line.substring(3), style: tt.titleSmall),
        ));
      } else if (line.startsWith('# ')) {
        flush();
        blocks.add(Text(line.substring(2), style: tt.titleMedium));
      } else if (numbered != null) {
        flush();
        blocks.add(item('${numbered.group(1)}.', numbered.group(2)!));
      } else if (line.trimLeft().startsWith('- ')) {
        flush();
        blocks.add(item('•', line.trimLeft().substring(2)));
      } else {
        para.add(line.trim());
      }
    }
    flush();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: blocks);
  }
}
