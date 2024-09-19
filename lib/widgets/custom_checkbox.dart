import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';

// ignore: must_be_immutable
class CustomCheckbox extends StatefulWidget {
  Function onChange;
  bool rememberUser;

  CustomCheckbox({
    super.key,
    required this.onChange,
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
    return Container(
        transform: Matrix4.translationValues(-5, 0, 0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 3, // Adjust the spacing between the widgets if needed
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberUser = !_rememberUser;
                  widget.onChange(_rememberUser);
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GradientIcon(
                  icon: _rememberUser
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
            const Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text(
                "Remember me",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ));
  }
}
