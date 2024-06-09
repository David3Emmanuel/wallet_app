import 'package:flutter/material.dart';

class TexturedContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final double opacity;

  const TexturedContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        image: DecorationImage(
          image: const AssetImage('assets/images/summary_bg_transparent.png'),
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(opacity),
            BlendMode.dstATop,
          ),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: child,
    );
  }
}
