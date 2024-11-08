import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';

// ignore: must_be_immutable
class CustomCheckbox extends StatefulWidget {
  Function onChange;
  bool checkboxValue;
  Widget child;

  CustomCheckbox({
    super.key,
    required this.onChange,
    required this.checkboxValue,
    required this.child,
  });

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool _checkboxValue = false;

  @override
  void initState() {
    super.initState();
    _checkboxValue = widget.checkboxValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        transform: Matrix4.translationValues(-5, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  _checkboxValue = !_checkboxValue;
                  widget.onChange(_checkboxValue);
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GradientIcon(
                  icon: _checkboxValue
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  gradient: const LinearGradient(
                    colors: [Color(0xffa16ae8), Color(0xff94b9ff)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  size: 30,
                ),
              ),
            ),

            // checkbox title/prompt
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 11, left: 2),
                child: widget.child,
              ),
            )
          ],
        ));
  }
}
