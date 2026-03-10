import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'home_shell.dart';

class SplashIntroPage extends StatefulWidget {
  const SplashIntroPage({super.key});

  @override
  State<SplashIntroPage> createState() => _SplashIntroPageState();
}

class _SplashIntroPageState extends State<SplashIntroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      await _controller.forward();

      if (!mounted) return;

      _navTimer = Timer(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const HomeShell(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF7ED8D1);
    const bg = Color(0xFF3A3A3A);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final opacity = Curves.easeIn.transform(
              (_controller.value / 0.2).clamp(0.0, 1.0),
            );

            final scale = Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).transform(
              Curves.easeOutBack.transform(_controller.value.clamp(0.0, 1.0)),
            );

            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _controller.value * 4 * pi,
                      child: child,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'HIKARI',
                      style: TextStyle(
                        color: brand,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Image(
            image: AssetImage('assets/icon.png'),
          )        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7ED8D1).withOpacity(0.22),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Image.asset(
              'assets/icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}