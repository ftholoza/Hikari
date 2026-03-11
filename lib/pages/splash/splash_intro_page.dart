import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../home/home_shell.dart';

class SplashIntroPage extends StatefulWidget {
  const SplashIntroPage({super.key});

  @override
  State<SplashIntroPage> createState() => _SplashIntroPageState();
}

class _SplashIntroPageState extends State<SplashIntroPage>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _blueController;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _blueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;

      await _logoController.forward();
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      await _blueController.forward();
      if (!mounted) return;

      _navTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 450),
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
    _logoController.dispose();
    _blueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF4F69E0);
    const darkBg = Color(0xFF3A3A3A);

    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 1.0;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _blueController]),
        builder: (context, _) {
          final blueBgProgress =
              Curves.easeInOut.transform(_blueController.value);

          final blueProgress = _blueController.value;

          final logoOpacity = 1.0 - blueBgProgress;
          final textOpacity = 1.0 - blueBgProgress;

          final bgColor = Color.lerp(darkBg, brand, blueBgProgress)!;

          final logoEnterOpacity = Curves.easeIn.transform(
            (_logoController.value / 0.2).clamp(0.0, 1.0),
          );

          final logoScale = Tween<double>(
            begin: 0.9,
            end: 1.0,
          ).transform(
            Curves.easeOutBack.transform(_logoController.value.clamp(0.0, 1.0)),
          );

          final delayedLogoProgress =
              ((blueProgress - 0.45) / 0.55).clamp(0.0, 1.0);

          final blueLogoOpacity =
              Curves.easeOut.transform(delayedLogoProgress);

          final blueLogoScale = Tween<double>(
            begin: 0.92,
            end: 1.0,
          ).transform(
            Curves.easeOutCubic.transform(delayedLogoProgress),
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: bgColor),

              Center(
                child: Opacity(
                  opacity: logoOpacity,
                  child: Transform.scale(
                    scale: logoScale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Opacity(
                          opacity: logoEnterOpacity,
                          child: Transform.rotate(
                            angle: _logoController.value * 4 * pi,
                            child: Image.asset(
                              'assets/icon2.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Opacity(
                          opacity: textOpacity * logoEnterOpacity,
                          child: const Text(
                            'HIKARI',
                            style: TextStyle(
                              color: brand,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Center(
                child: Opacity(
                  opacity: blueLogoOpacity,
                  child: Transform.scale(
                    scale: blueLogoScale,
                    child: Image.asset(
                      'assets/icon1.png',
                      width: screenWidth * 0.95,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}