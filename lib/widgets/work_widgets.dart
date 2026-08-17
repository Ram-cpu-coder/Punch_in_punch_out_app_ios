part of '../main.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({
    super.key,
    required this.initialNote,
    required this.enabled,
    required this.onSave,
  });

  final String initialNote;
  final bool enabled;
  final Future<void> Function(String value) onSave;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialNote);
    focusNode = FocusNode()..addListener(handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant NoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialNote != widget.initialNote &&
        controller.text != widget.initialNote) {
      controller.text = widget.initialNote;
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(handleFocusChange);
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  void handleFocusChange() {
    if (!focusNode.hasFocus) save();
  }

  Future<void> save() async {
    if (saving || controller.text.trim() == widget.initialNote.trim()) return;
    setState(() => saving = true);
    try {
      await widget.onSave(controller.text);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: widget.enabled && !saving,
        minLines: 1,
        maxLines: 3,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          focusNode.unfocus();
          save();
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.sticky_note_2_outlined),
          hintText: 'Add note',
          border: InputBorder.none,
          suffixIcon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(Icons.edit_note_outlined),
        ),
      ),
    );
  }
}
