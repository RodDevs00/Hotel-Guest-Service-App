import 'package:flutter/material.dart';

class Breakpoints {
  static const double compact = 700;
  static const double medium = 1000;
}

bool isCompactLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width < Breakpoints.compact;

bool isMediumLayout(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= Breakpoints.compact && width < Breakpoints.medium;
}

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.medium;

EdgeInsets pagePadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < Breakpoints.compact) {
    return const EdgeInsets.fromLTRB(16, 16, 16, 16);
  }
  if (width < Breakpoints.medium) {
    return const EdgeInsets.fromLTRB(20, 20, 20, 20);
  }
  return const EdgeInsets.fromLTRB(24, 24, 24, 24);
}
