import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/haven_logo.dart';

class PrivacyNoticeScreen extends StatelessWidget {
  const PrivacyNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: HavenLogo()),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: Container(
                            color: AppColors.softTealFill,
                            child: const Icon(
                              Icons.hotel_outlined,
                              size: 64,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Your stay, respected',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hotel Service connects your room directly to hotel staff during your stay. '
                        'We only store your room number, check-in code, and active service request notes '
                        'to fulfill your requests promptly.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.muted,
                              height: 1.5,
                            ),
                      ),
                      const SizedBox(height: 20),
                      const _PrivacyPoint(
                        icon: Icons.lock_outline,
                        title: 'Encrypted communication',
                        subtitle: 'Direct and isolated staff-to-room channel',
                      ),
                      const SizedBox(height: 10),
                      const _PrivacyPoint(
                        icon: Icons.location_off_outlined,
                        title: 'No tracking beacons',
                        subtitle: 'Only room and request details are used',
                      ),
                      const SizedBox(height: 10),
                      const _PrivacyPoint(
                        icon: Icons.delete_outline,
                        title: 'Stay-scoped data',
                        subtitle: 'Codes and guest session end with your stay',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/guest/sign-in'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Continue'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Guest data protection standard',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.softTealFill,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(icon, color: AppColors.teal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
