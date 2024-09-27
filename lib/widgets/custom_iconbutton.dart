import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SizedIconButton extends StatefulWidget {
  double size;
  IconData icon;
  Color iconColor;
  Function onPressed;

  SizedIconButton({
    super.key,
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
  });

  @override
  State<SizedIconButton> createState() => _SizedIconButtonState();
}

class _SizedIconButtonState extends State<SizedIconButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      child: Container(
        transform: Matrix4.translationValues(0, -(widget.size / 6), 0),
        child: IconButton(
          tooltip: "Medicines",
          icon: Icon(
            widget.icon,
            color: widget.iconColor,
            size: widget.size,
          ),
          onPressed: () {
            widget.onPressed;
          },
        ),
      ),
    );
  }
}
