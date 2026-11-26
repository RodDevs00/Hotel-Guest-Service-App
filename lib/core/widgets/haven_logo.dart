import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HavenLogo extends StatelessWidget {
  const HavenLogo({
    super.key,
    this.height = 28,
    this.showWordmark = true,
    this.compact = false,
  });

  final double height;
  final bool showWordmark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: height,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(height * 0.22),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.vpn_key_rounded,
        color: Colors.white,
        size: height * 0.55,
      ),
    );

    if (!showWordmark) return mark;

    final style = Theme.of(context).textTheme.titleLarge;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: compact ? 8 : 10),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Hotel',
                style: style?.copyWith(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  height: 1,
                ),
              ),
              TextSpan(
                text: ' Service',
                style: style?.copyWith(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.teal,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
