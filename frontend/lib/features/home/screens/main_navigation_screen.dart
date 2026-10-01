import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';
import '../config/navigation_config.dart';
import '../../presensi/screens/guru_presensi_screen.dart';
import '../../presensi/screens/presensi_camera_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;



  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final screens = NavigationConfig.getScreensForRole(user, (index) {
      setState(() {
        _currentIndex = index;
      });
    });
    final navItems = NavigationConfig.getNavItemsForRole(user);

    // Mencegah crash jika user null setelah logout saat _currentIndex > 0
    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    final isNonSiswa = user?.role != UserRole.siswa;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      floatingActionButton: isNonSiswa
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PresensiCameraScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: Icon(PhosphorIcons.fingerprint(PhosphorIconsStyle.bold), color: AppColors.surface, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomAppBar(
          color: AppColors.surface,
          elevation: 20,
          shadowColor: AppColors.onBackground.withValues(alpha: 0.1),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.zero,
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.onSurface.withValues(alpha: 0.75),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: 28,
              currentIndex: safeIndex,
              onTap: (index) {
                // Prevent tapping the dummy index (2) for non-siswa
                if (isNonSiswa && index == 2) return;
                
                setState(() {
                  _currentIndex = index;
                });
              },
              items: navItems,
            ),
        ),
      ),
    );
  }
}

