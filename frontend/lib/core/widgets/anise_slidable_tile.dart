import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../utils/responsive.dart';

/// Komponen geser (CRUD Swipe Action) terstandarisasi untuk item baris daftar Anise.
/// Menyediakan aksi swipe cepat (Edit, Freeze/Aktifkan, Hapus) dengan warna token,
/// ikon Phosphor fill seragam, dan rasio lebar otomatis.
class AniseSlidableTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onFreeze;
  final bool isFrozen;
  final String editLabel;
  final String deleteLabel;
  final String? freezeLabel;

  const AniseSlidableTile({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.onFreeze,
    this.isFrozen = false,
    this.editLabel = 'Edit',
    this.deleteLabel = 'Hapus',
    this.freezeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];

    if (onEdit != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onEdit!(),
          backgroundColor: AppColors.warning,
          foregroundColor: Colors.white,
          icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.fill),
          label: editLabel,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(12.w(context))),
        ),
      );
    }

    if (onFreeze != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onFreeze!(),
          backgroundColor: AppColors.menuPastelBlue,
          foregroundColor: Colors.white,
          icon: PhosphorIcons.snowflake(PhosphorIconsStyle.fill),
          label: freezeLabel ?? (isFrozen ? 'Aktifkan' : 'Freeze'),
          borderRadius: onEdit == null ? BorderRadius.horizontal(left: Radius.circular(12.w(context))) : BorderRadius.zero,
        ),
      );
    }

    if (onDelete != null) {
      actions.add(
        SlidableAction(
          onPressed: (_) => onDelete!(),
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          icon: PhosphorIcons.trash(PhosphorIconsStyle.fill),
          label: deleteLabel,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(12.w(context))),
        ),
      );
    }

    if (actions.isEmpty) {
      return child;
    }

    final double extentRatio = actions.length == 3 ? 0.65 : (actions.length == 2 ? 0.45 : 0.25);

    return Slidable(
      key: key ?? UniqueKey(),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: extentRatio,
        children: actions,
      ),
      child: child,
    );
  }
}
