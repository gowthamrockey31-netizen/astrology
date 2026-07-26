import 'package:flutter/material.dart';

class ServiceItem {
  final String id;
  final String title;
  final String tamilTitle;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final List<Color> gradientColors;

  ServiceItem({
    required this.id,
    required this.title,
    required this.tamilTitle,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.gradientColors,
  });
}
