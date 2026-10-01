import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HabitModel {
  final String title;
  final String subtitle;
  final bool checked;
  final IconData icon;

  HabitModel({required this.title, required this.subtitle, required this.checked, required this.icon});

  HabitModel copyWith({bool? checked}) {
    return HabitModel(
      title: title,
      subtitle: subtitle,
      checked: checked ?? this.checked,
      icon: icon,
    );
  }
}

class HabitNotifier extends StateNotifier<List<HabitModel>> {
  HabitNotifier() : super([
    HabitModel(title: 'Bangun Pagi', subtitle: 'Sebelum jam 05:00', checked: false, icon: PhosphorIcons.sun(PhosphorIconsStyle.fill)),
    HabitModel(title: 'Beribadah', subtitle: 'Sesuai agama masing-masing', checked: false, icon: PhosphorIcons.handsPraying(PhosphorIconsStyle.fill)),
    HabitModel(title: 'Berolahraga', subtitle: 'Minimal 15 menit', checked: false, icon: PhosphorIcons.sneaker(PhosphorIconsStyle.fill)),
    HabitModel(title: 'Makan Sehat', subtitle: 'Sayur, lauk, dan buah', checked: false, icon: PhosphorIcons.carrot(PhosphorIconsStyle.fill)),
    HabitModel(title: 'Gemar Belajar', subtitle: 'Membaca atau mengulang materi', checked: false, icon: PhosphorIcons.bookOpen(PhosphorIconsStyle.fill)),
    HabitModel(title: 'Bermasyarakat', subtitle: 'Bersosialisasi & berbuat baik', checked: false, icon: PhosphorIcons.users(PhosphorIconsStyle.fill)),
    HabitModel(title: 'Tidur Cepat', subtitle: 'Sebelum jam 22:00', checked: false, icon: PhosphorIcons.moon(PhosphorIconsStyle.fill)),
  ]);

  void toggleHabit(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) state[i].copyWith(checked: !state[i].checked) else state[i],
    ];
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<HabitModel>>((ref) {
  return HabitNotifier();
});
