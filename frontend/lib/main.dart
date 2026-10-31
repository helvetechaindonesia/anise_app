import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/main_navigation_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'core/constants/colors.dart';
import 'core/utils/local_notification_helper.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  if (!kIsWeb) {
    await LocalNotificationHelper.initialize();
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) {
      final user = ref.watch(authProvider).user;
      if (user == null) {
        Future.microtask(() => ref.read(authProvider.notifier).loginAsDemo());
      }
    }

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'Anise Smart Education',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: kIsWeb ? const MainNavigationScreen() : const SplashScreen(),
    );
  }
}
