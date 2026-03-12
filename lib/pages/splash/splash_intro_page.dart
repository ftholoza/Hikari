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
  late final AnimationController _masterController;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('SplashIntroPage initState');

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        debugPrint('Splash post frame start');

        await precacheImage(const AssetImage('assets/icon1.png'), context);
        await precacheImage(const AssetImage('assets/icon2.png'), context);
        await precacheImage(const AssetImage('assets/icon3.png'), context);

        debugPrint('Splash assets preloaded');

        await Future.delayed(const Duration(milliseconds: 40));
        if (!mounted) return;

        debugPrint('Splash animation forward start');
        await _masterController.forward();
        if (!mounted) return;
        debugPrint('Splash animation forward done');

        _navTimer = Timer(const Duration(milliseconds: 250), () {
          if (!mounted) return;
          debugPrint('Navigation vers HomeShell');

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (_, __, ___) {
                debugPrint('HomeShell pageBuilder appelé');
                return const HomeShell();
              },
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });
      } catch (e, s) {
        debugPrint('Erreur SplashIntroPage: $e');
        debugPrint('$s');
      }
    });
  }

  @override
  void dispose() {
    debugPrint('SplashIntroPage dispose');
    _navTimer?.cancel();
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF4F69E0);
    const darkBg = Color(0xFF3A3A3A);

    const logoSize = 138.0;
    const wordmarkWidth = 170.0;

    final screenWidth = MediaQuery.of(context).size.width;
    final t = _masterController;

    return Scaffold(
      body: AnimatedBuilder(
        animation: t,
        builder: (context, _) {
          final backgroundProgress = CurvedAnimation(
            parent: t,
            curve: const Interval(0.58, 0.82, curve: Curves.easeInOutCubic),
          ).value;

          final bgColor = Color.lerp(darkBg, brand, backgroundProgress)!;

          final logoFadeOut = 1.0 -
              CurvedAnimation(
                parent: t,
                curve: const Interval(0.60, 0.78, curve: Curves.easeOutCubic),
              ).value;

          final wordmarkOpacity = CurvedAnimation(
                parent: t,
                curve: const Interval(0.18, 0.46, curve: Curves.easeOutCubic),
              ).value *
              logoFadeOut;

          final rotationProgress = CurvedAnimation(
            parent: t,
            curve: const Interval(0.02, 0.56, curve: Curves.easeInOut),
          ).value;

          final rotationAngle = rotationProgress * 2.8 * pi;

          final logoScale = Tween<double>(
            begin: 1.0,
            end: 1.015,
          ).transform(
            CurvedAnimation(
              parent: t,
              curve: const Interval(0.00, 0.50, curve: Curves.easeInOut),
            ).value,
          );

          final finalLogoOpacity = CurvedAnimation(
            parent: t,
            curve: const Interval(0.72, 0.94, curve: Curves.easeOutCubic),
          ).value;

          final finalLogoScale = Tween<double>(
            begin: 0.965,
            end: 1.0,
          ).transform(
            CurvedAnimation(
              parent: t,
              curve: const Interval(0.72, 0.97, curve: Curves.easeOutCubic),
            ).value,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: bgColor),

              Center(
                child: Transform.translate(
                  offset: const Offset(0, 38),
                  child: Opacity(
                    opacity: logoFadeOut,
                    child: Transform.scale(
                      scale: logoScale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: rotationAngle,
                            child: Image.asset(
                              'assets/icon2.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                              errorBuilder: (_, error, stackTrace) {
                                debugPrint('Erreur asset icon2.png: $error');
                                return const SizedBox(
                                  width: logoSize,
                                  height: logoSize,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          Opacity(
                            opacity: wordmarkOpacity,
                            child: Image.asset(
                              'assets/icon3.png',
                              width: wordmarkWidth,
                              fit: BoxFit.contain,
                              errorBuilder: (_, error, stackTrace) {
                                debugPrint('Erreur asset icon3.png: $error');
                                return const SizedBox(
                                  width: wordmarkWidth,
                                  height: 40,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: Opacity(
                  opacity: finalLogoOpacity,
                  child: Transform.scale(
                    scale: finalLogoScale,
                    child: Image.asset(
                      'assets/icon1.png',
                      width: screenWidth * 0.92,
                      fit: BoxFit.contain,
                      errorBuilder: (_, error, stackTrace) {
                        debugPrint('Erreur asset icon1.png: $error');
                        return const SizedBox.shrink();
                      },
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