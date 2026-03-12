import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Future<void>? _navFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _navigate();
  }

  @override
  void dispose() {
    _navFuture = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            _StripedLoader(animation: _controller),
            const SizedBox(height: 16),
            const Text(
              'LOADING....',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    if (!seen) {
      await prefs.setBool('onboarding_seen', true);
      context.go('/onboard');
    } else {
      context.go('/home');
    }
  }
}

class _StripedLoader extends StatelessWidget {
  const _StripedLoader({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 34,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          const Positioned.fill(top: 1, bottom: 1, child: SizedBox()),
          Container(
            width: double.infinity,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  size: const Size(double.infinity, 18),
                  painter: _StripePainter(progress: animation.value),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final stripeHeight = size.height - 8;
    final offsetY = (size.height - stripeHeight) / 2;
    final width = size.width * progress;
    const stripeWidth = 4.0;
    const gap = stripeWidth / 2;
    const tilt = 3.0;
    canvas.save();
    canvas.translate(0, offsetY);
    for (
      double x = -stripeHeight;
      x < width + stripeWidth;
      x += stripeWidth + gap
    ) {
      final path = Path()
        ..moveTo(x, stripeHeight)
        ..lineTo(x + tilt, stripeHeight)
        ..lineTo(x + tilt + stripeWidth, 0)
        ..lineTo(x + stripeWidth, 0)
        ..close();
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, width, stripeHeight));
      canvas.drawPath(path, paint);
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StripePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
