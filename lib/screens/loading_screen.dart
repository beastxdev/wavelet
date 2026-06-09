import 'dart:math' as math;

import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.next});

  final Widget next;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 520),
          pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(opacity: animation, child: widget.next),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05080C),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final pulse = 0.5 + math.sin(_controller.value * math.pi * 2) * 0.5;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 138,
                  height: 138,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1ED760).withValues(alpha: 0.18 + pulse * 0.18),
                        blurRadius: 34 + pulse * 18,
                        spreadRadius: 4 + pulse * 5,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: 0.96 + pulse * 0.04,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset('assets/branding/wavelet_logo.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Wavelet',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 96,
                  height: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final phase = ((_controller.value + index * 0.13) % 1);
                      return Container(
                        width: 8,
                        height: 8 + math.sin(phase * math.pi) * 16,
                        decoration: BoxDecoration(
                          color: Color.lerp(const Color(0xFF1ED760), const Color(0xFF39A7FF), index / 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
