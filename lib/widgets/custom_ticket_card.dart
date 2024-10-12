import 'dart:ui';
import 'package:flutter/material.dart';

class TicketWidget extends StatefulWidget {
  const TicketWidget({
    super.key,
    required this.margin,
    required this.padding,
    required this.child,
    required this.width,
    required this.height,
    this.color = Colors.white,
  });

  final EdgeInsets margin;
  final EdgeInsets padding;
  final Widget child;
  final double width;
  final double height;
  final Color color;

  @override
  State<TicketWidget> createState() => _TicketWidgetState();
}

class _TicketWidgetState extends State<TicketWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Clipped card shadow (blurred by BackdropFilter widget)
        ClipPath(
          clipper: TicketClipper(),
          child: Container(
            width: (widget.width + 1),
            height: (widget.height + 1),
            color: const Color.fromARGB(44, 0, 0, 0),
            padding: widget.padding,
            margin: widget.margin,
            child: widget.child,
          ),
        ),
        ClipRect(
          // applies blurring filter to create shadow
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4.0,
              sigmaY: 4.0,
            ),
            child: ClipPath(
              clipper: TicketClipper(),
              child: Container(
                width: widget.width,
                height: widget.height,
                padding: widget.padding,
                margin: widget.margin,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    color: widget.color),
                child: widget.child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);

    var circleRadius = 10.0;
    var circleAmount = size.width / circleRadius;
    // coordinates
    var centerX = circleRadius * 3; // initialize x-axis start
    var centerY = size.height - 15; // clip semicircles from bottom of receipt

    for (var i = 0; i < circleAmount; i++) {
      path.addOval(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: circleRadius,
      ));

      centerX += (circleRadius * 2.5);
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
