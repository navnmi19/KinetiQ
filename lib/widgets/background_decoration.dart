import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackgroundDecorations extends StatelessWidget {
  const BackgroundDecorations({super.key});

  static const Color orange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            _decor(
              'assets/illustrations/machine.svg',
              top: -20,
              left: -30,
              size: 170,
              angle: -0.15,
            ),

            _decor(
              'assets/illustrations/barbell.svg',
              top: 40,
              right: -40,
              size: 190,
              angle: 0.4,
            ),

            _decor(
              'assets/illustrations/running.svg',
              top: size.height * 0.32,
              left: -40,
              size: 160,
              angle: 0.1,
            ),

            _decor(
              'assets/illustrations/gripper.svg',
              top: size.height * 0.30,
              right: -30,
              size: 150,
              angle: -0.3,
            ),

            // WHITE DUMBBELL
            _decor(
              'assets/illustrations/dumbbell.svg',
              bottom: size.height * 0.22,
              left: -35,
              size: 150,
              angle: 0.2,
              color: Colors.white,
            ),

            _decor(
              'assets/illustrations/fitnesswatch.svg',
              bottom: size.height * 0.20,
              right: -30,
              size: 160,
              angle: -0.1,
            ),

            _decor(
              'assets/illustrations/pushups.svg',
              bottom: -30,
              left: -20,
              size: 180,
              angle: 0.15,
            ),

            _decor(
              'assets/illustrations/cycling.svg',
              bottom: -20,
              right: -40,
              size: 190,
              angle: -0.25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _decor(
    String assetPath, {
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    double angle = 0,
    Color color = orange,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: 0.08,
          child: SvgPicture.asset(
            assetPath,
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}