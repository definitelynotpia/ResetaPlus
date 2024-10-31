import 'package:flutter/material.dart';
import 'package:gradient_icon/gradient_icon.dart';

class CustomRadioWidget<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final Widget title;
  final ValueChanged<T> onChanged;
  final double width;
  final double height;

  const CustomRadioWidget({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
    this.width = 30,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          onChanged(this.value);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              transform: Matrix4.translationValues(0, -16, 0),
              child: value == groupValue
                  ? GradientIcon(
                      icon: Icons.check_circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xffa16ae8), Color(0xff94b9ff)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      size: this.width,
                    )
                  : GradientIcon(
                      icon: Icons.circle_outlined,
                      gradient: const LinearGradient(
                        colors: [Color(0xffa16ae8), Color(0xff94b9ff)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      size: this.width,
                    ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: this.title,
            ),
          ],
        ),
      ),
    );
  }
}
