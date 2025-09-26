import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3F7FF), Color(0xFFEAF2FF), Color(0xFFE6ECFF)],
        ),
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(
            top: -60,
            left: -40,
            child: _bubble(140, Color(0xFFB28DDB).withOpacity(0.18)),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: _bubble(180, Color(0xFF8D61B4).withOpacity(0.16)),
          ),
          Positioned(
            top: 120,
            right: -20,
            child: _bubble(90, Color(0xFF6E72C3).withOpacity(0.14)),
          ),
          Positioned(
            bottom: 120,
            left: -10,
            child: _bubble(80, Color(0xFF198CCA).withOpacity(0.12)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 24,
            spreadRadius: 6,
          ),
        ],
      ),
    );
  }
}
