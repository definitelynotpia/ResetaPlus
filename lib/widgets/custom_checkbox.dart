import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';

// ignore: must_be_immutable
class CustomCheckbox extends StatefulWidget {
  double? size;
  double? iconSize;
  Function onChange;
  IconData? icon;
  bool rememberUser;

  CustomCheckbox({
    super.key,
    this.size,
    this.iconSize,
    required this.onChange,
    this.icon,
    required this.rememberUser,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _rememberUser = false;

  @override
  void initState() {
    super.initState();
    _rememberUser = widget.rememberUser;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _rememberUser = !_rememberUser;
          widget.onChange(_rememberUser);
        });
      },
      child: AnimatedContainer(
        height: widget.size ?? 28,
        width: widget.size ?? 28,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
        child: GradientIcon(
          icon: _rememberUser ? Icons.check_box : Icons.check_box_outline_blank,
          gradient: const LinearGradient(
            colors: [Color(0xffa16ae8), Color(0xff94b9ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          // size: 30,
        ),
      ),
    );
  }
}
