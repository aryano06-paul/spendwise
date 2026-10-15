import 'package:flutter/material.dart';

/// Disposes the given controllers only when the sheet or dialog that uses them
/// is really removed from the widget tree (after its close animation), never
/// earlier. Disposing right after `await showModalBottomSheet(...)` or
/// `await showDialog(...)` is too early and causes
/// "A TextEditingController was used after being disposed".
class ControllerScope extends StatefulWidget {
  const ControllerScope({super.key, required this.controllers, required this.child});

  final List<TextEditingController> controllers;
  final Widget child;

  @override
  State<ControllerScope> createState() => _ControllerScopeState();
}

class _ControllerScopeState extends State<ControllerScope> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
