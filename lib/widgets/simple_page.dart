import 'package:flutter/material.dart';

class SimplePage extends StatelessWidget {
  final String title;

  const SimplePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFF4F69E0);
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 92,
            width: double.infinity,
            color: brand,
            alignment: Alignment.center,
            child: const Text(
              'HIKARI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}