import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../features/auth/models/user_model.dart';
import '../screens/siswa_home_screen.dart';
import '../screens/guru_home_screen.dart';
import '../screens/bk_home_screen.dart';
import '../../tata_usaha/screens/tu_home_screen.dart';
import '../../tata_usaha/screens/tu_surat_screen.dart';
import '../../bk/screens/bk_bimbingan_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../../jadwal/screens/jadwal_screen.dart';
import '../../jadwal/screens/guru_jurnal_screen.dart';
import '../../poin/screens/poin_screen.dart';
import '../../profile/screens/siswa_profile_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../screens/role_dashboards.dart';

class NavigationConfig {
  static List<Widget> getScreensForRole(UserModel? user, Function(int) onNavigateTab) {
    if (user == null) return [const Center(child: Text("Unauthorized"))];

    if (user.role == UserRole.siswa) {
      return [
        SiswaHomeScreen(onNavigateTab: onNavigateTab),
        const JadwalScreen(),
        const PoinScreen(),
        const ProfileScreen(),
      ];
    }

    final baseScreens = <Widget>[
      RoleDashboardPlaceholder(title: 'Dashboard ${user.role.name.toUpperCase()}', role: user.role),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    if (user.role == UserRole.pengajar) {
      // Index 0: Home, Index 1: Jurnal, Index 2: Dummy (FAB), Index 3: KPI (PoinScreen), Index 4: Profile
      return [
        GuruHomeScreen(onNavigateTab: onNavigateTab),
        const GuruJurnalScreen(),
        const SizedBox(), // Placeholder untuk Center FAB Presensi
        const PoinScreen(),
        const ProfileScreen(),
      ];
    } else if (user.role == UserRole.bk) {
      return [
        BkHomeScreen(onNavigateTab: onNavigateTab),
        const BkBimbinganScreen(),
        const SizedBox(), // Placeholder FAB Presensi
        const PoinScreen(),
        const ProfileScreen(),
      ];
    } else if (user.role == UserRole.tataUsaha) {
      return [
        TuHomeScreen(onNavigateTab: onNavigateTab),
        const TuSuratScreen(),
        const SizedBox(), // Placeholder FAB Presensi
        const PoinScreen(),
        const ProfileScreen(),
      ];
    } else if (user.role == UserRole.kepalaSekolah) {
      baseScreens.insert(1, const RoleDashboardPlaceholder(title: 'Laporan Eksekutif', role: UserRole.kepalaSekolah));
    } else {
       baseScreens.insert(1, RoleDashboardPlaceholder(title: 'Modul Khusus ${user.role.name}', role: user.role));
    }

    return baseScreens;
  }

  static List<BottomNavigationBarItem> getNavItemsForRole(UserModel? user) {
    if (user == null) {
      return [
        BottomNavigationBarItem(icon: Icon(PhosphorIcons.house()), label: ''),
        BottomNavigationBarItem(icon: Icon(PhosphorIcons.house()), label: ''),
      ];
    }

    if (user.role == UserRole.siswa) {
      return [
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.house()),
          activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.calendarBlank()),
          activeIcon: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill)),
          label: 'Jadwal',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.star()),
          activeIcon: Icon(PhosphorIcons.star(PhosphorIconsStyle.fill)),
          label: 'Poin',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.user()),
          activeIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
          label: 'Profile',
        ),
      ];
    }

    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(PhosphorIcons.house()),
        activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
        label: 'Beranda',
      ),
    ];

    if (user.role == UserRole.pengajar) {
      return [
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.house()),
          activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.chalkboardTeacher()),
          activeIcon: Icon(PhosphorIcons.chalkboardTeacher(PhosphorIconsStyle.fill)),
          label: 'Jurnal',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.clear, color: Colors.transparent),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.chartLineUp()),
          activeIcon: Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill)),
          label: 'KPI',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.user()),
          activeIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
          label: 'Profil',
        ),
      ];
    } else if (user.role == UserRole.bk) {
      return [
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.house()),
          activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.usersThree()),
          activeIcon: Icon(PhosphorIcons.usersThree(PhosphorIconsStyle.fill)),
          label: 'Bimbingan',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.clear, color: Colors.transparent),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.chartLineUp()),
          activeIcon: Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill)),
          label: 'KPI',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.user()),
          activeIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
          label: 'Profil',
        ),
      ];
    } else if (user.role == UserRole.kepalaSekolah) {
      items.add(BottomNavigationBarItem(
        icon: Icon(PhosphorIcons.chartLineUp()),
        activeIcon: Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill)),
        label: 'Laporan',
      ));
    } else if (user.role == UserRole.tataUsaha) {
      return [
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.house()),
          activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.envelope()),
          activeIcon: Icon(PhosphorIcons.envelope(PhosphorIconsStyle.fill)),
          label: 'Surat',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.clear, color: Colors.transparent),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.chartLineUp()),
          activeIcon: Icon(PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill)),
          label: 'KPI',
        ),
        BottomNavigationBarItem(
          icon: Icon(PhosphorIcons.user()),
          activeIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
          label: 'Profil',
        ),
      ];
    } else {
       items.add(BottomNavigationBarItem(
        icon: Icon(PhosphorIcons.squaresFour()),
        activeIcon: Icon(PhosphorIcons.squaresFour(PhosphorIconsStyle.fill)),
        label: 'Modul',
      ));
    }

    items.addAll([
      BottomNavigationBarItem(
        icon: Icon(PhosphorIcons.bell()),
        activeIcon: Icon(PhosphorIcons.bell(PhosphorIconsStyle.fill)),
        label: 'Notifikasi',
      ),
      BottomNavigationBarItem(
        icon: Icon(PhosphorIcons.user()),
        activeIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
        label: 'Profil',
      ),
    ]);

    return items;
  }
}


