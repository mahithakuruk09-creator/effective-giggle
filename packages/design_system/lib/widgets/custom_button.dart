import 'package:flutter/material.dart';
import '../typography.dart';
import '../colors.dart';

class ScredexButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const ScredexButton({super.key, required this.label, this.onPressed});

  @override
  State<ScredexButton> createState() => _ScredexButtonState();
}

class _ScredexButtonState extends State<ScredexButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: ScredexColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (_pressed)
              BoxShadow(
                color: ScredexColors.accent.withOpacity(0.6),
                blurRadius: 12,
              )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onPressed,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              child:
                  Text(widget.label, style: ScredexTypography.body, textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
