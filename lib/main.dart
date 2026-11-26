import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey, // ignore: deprecated_member_use
    );
  }

  runApp(const ProviderScope(child: HotelGuestServiceApp()));
}

class HotelGuestServiceApp extends ConsumerWidget {
  const HotelGuestServiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!AppConfig.hasSupabaseConfig) {
      return MaterialApp(
        title: 'Hotel Service',
        theme: AppTheme.light(),
        home: const _MissingConfigScreen(),
      );
    }

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Hotel Service',
      theme: AppTheme.light(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_suggest, size: 48, color: AppColors.navy),
                SizedBox(height: 16),
                Text(
                  'Supabase config missing',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Run the app with:\n\n'
                  'flutter run --dart-define=SUPABASE_URL=YOUR_URL '
                  '--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY'
                  '${kIsWeb ? ' -d chrome' : ''}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
