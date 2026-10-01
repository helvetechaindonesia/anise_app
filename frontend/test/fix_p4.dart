import 'dart:io';

void main() {
  final file = File('f:/projek/anise_app/frontend/lib/features/presensi/widgets/presensi_riwayat_list_widget.dart');
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();
  
  // Make it transparent
  content = content.replaceAll("color: AppColors.surface,\n        borderRadius: BorderRadius.circular(16.w(context)),\n        border: Border.all(color: AppColors.outline),\n        boxShadow: [\n          BoxShadow(\n            color: AppColors.onBackground.withValues(alpha: 0.05),\n            blurRadius: 8,\n            offset: const Offset(0, 4),\n          ),\n        ],", "color: Colors.transparent,");
  
  // Remove margin
  content = content.replaceAll("margin: EdgeInsets.only(bottom: 12.h(context)),", "margin: EdgeInsets.zero,");
  
  // Update texts to onBackground
  content = content.replaceAll("color: AppColors.onSurface,", "color: AppColors.onBackground,");
  content = content.replaceAll("color: AppColors.onSurface.withValues(alpha: 0.7)", "color: AppColors.onBackground.withValues(alpha: 0.7)");
  content = content.replaceAll("color: AppColors.onSurface.withValues(alpha: 0.8)", "color: AppColors.onBackground.withValues(alpha: 0.8)");
  
  // Also we need to add the separator line between items.
  // Instead of map().toList(), we can just add a divider in map
  // Let's rewrite the map part
  content = content.replaceAll("children: logData.map((log) => _buildLogItem(context, log)).toList(),", 
  "children: logData.asMap().entries.map((entry) {\n        final index = entry.key;\n        final log = entry.value;\n        final isLast = index == logData.length - 1;\n        return Column(\n          children: [\n            _buildLogItem(context, log),\n            if (!isLast)\n              Center(\n                child: Container(\n                  width: MediaQuery.of(context).size.width * 0.9,\n                  height: 1,\n                  color: AppColors.primary,\n                ),\n              ),\n          ],\n        );\n      }).toList(),");

  file.writeAsStringSync(content);
}
