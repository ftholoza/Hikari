import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class HikariHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final double height;

  const HikariHeader({
    super.key,
    this.showBackButton = false,
    this.onBackTap,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: onBackTap ?? () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              Center(
                child: Image.asset(
                  'assets/icon1.png',
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}