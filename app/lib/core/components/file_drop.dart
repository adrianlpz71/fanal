import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../tokens.dart';

/// Zona grande para soltar un fichero (web y escritorio, D5: `desktop_drop`) con el botón de
/// elegirlo. Estados: arrastrando encima, leyendo (`busy`) y no reconocido (`error`).
class FileDropZone extends StatefulWidget {
  const FileDropZone({
    super.key,
    required this.extensions,
    required this.onFile,
    this.busy = false,
    this.error,
    this.fileName,
    this.hint,
  });

  /// Extensiones admitidas, sin punto ("csv", "xlsx", "pdf").
  final List<String> extensions;
  final void Function(String name, Uint8List bytes) onFile;
  final bool busy;
  final String? error; // p. ej. "Formato no reconocido"
  final String? fileName; // el último fichero leído
  final String? hint; // una línea debajo (p. ej. "En Android, también desde Compartir")

  @override
  State<FileDropZone> createState() => _FileDropZoneState();
}

class _FileDropZoneState extends State<FileDropZone> {
  bool _over = false;
  String? _rejected;

  String get _formats => widget.extensions.map((e) => e.toUpperCase()).join(', ');

  bool _allowed(String name) {
    final dot = name.lastIndexOf('.');
    final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
    return widget.extensions.contains(ext);
  }

  Future<void> _accept(String name, Future<Uint8List> Function() read) async {
    if (!_allowed(name)) {
      setState(() => _rejected = '«$name» no es un formato admitido. Usa $_formats.');
      return;
    }
    setState(() => _rejected = null);
    widget.onFile(name, await read());
  }

  Future<void> _pick() async {
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: widget.extensions);
    if (files.isEmpty) return;
    final f = files.single;
    await _accept(f.name, f.xFile.readAsBytes);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final error = _rejected ?? widget.error;
    final border = _over ? cs.primary : (error != null ? cs.error : cs.outline);
    final (IconData icon, String title) = widget.busy
        ? (Icons.hourglass_top, 'Leyendo ${widget.fileName ?? 'el fichero'}…')
        : _over
            ? (Icons.file_download_outlined, 'Suelta el fichero aquí')
            : context.isCompact
                ? (Icons.upload_file, 'Elige el fichero') // en el móvil no se arrastra
                : (Icons.upload_file, 'Arrastra aquí el fichero');
    return DropTarget(
      enable: !widget.busy,
      onDragEntered: (_) => setState(() => _over = true),
      onDragExited: (_) => setState(() => _over = false),
      onDragDone: (d) async {
        setState(() => _over = false);
        if (d.files.isEmpty) return;
        final f = d.files.first;
        await _accept(f.name, f.readAsBytes);
      },
      child: AnimatedContainer(
        key: const Key('drop-zone'),
        duration: const Duration(milliseconds: 120),
        constraints: const BoxConstraints(minHeight: 200),
        padding: const EdgeInsets.all(Space.xl),
        decoration: BoxDecoration(
          color: _over ? cs.primaryContainer.withValues(alpha: 0.35) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: border, width: _over ? 2 : 1.2),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, spacing: Space.sm, children: [
          if (widget.busy)
            const SizedBox.square(dimension: 36, child: CircularProgressIndicator(strokeWidth: 3))
          else
            Icon(icon, size: 40, color: _over ? cs.primary : cs.onSurfaceVariant),
          Text(title, style: tt.titleMedium, textAlign: TextAlign.center),
          Text(_formats, style: FaroText.caption(context), textAlign: TextAlign.center),
          FilledButton.icon(
            key: const Key('pick-file'),
            icon: const Icon(Icons.folder_open),
            label: const Text('Elegir fichero'),
            onPressed: widget.busy ? null : _pick,
          ),
          if (widget.fileName != null && !widget.busy && error == null)
            Text('Último: ${widget.fileName}', style: FaroText.caption(context), textAlign: TextAlign.center),
          if (error != null)
            Row(mainAxisSize: MainAxisSize.min, spacing: Space.xs, children: [
              Icon(Icons.error_outline, size: 18, color: cs.error),
              Flexible(child: Text(error, style: tt.bodyMedium?.copyWith(color: cs.error), textAlign: TextAlign.center)),
            ]),
          if (widget.hint != null)
            Text(widget.hint!, style: FaroText.caption(context), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
