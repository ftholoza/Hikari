import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final String title;
  final String content;
  final bool mono;

  const AppCard({
    super.key,
    required this.title,
    required this.content,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontFamily: mono ? "monospace" : null,
              color: Colors.white.withOpacity(.9),
            ),
          ),
        ],
      ),
    );
  }
}