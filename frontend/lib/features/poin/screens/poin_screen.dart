import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_text_styles.dart';
import '../../../core/widgets/main_header.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/responsive.dart';

import '../widgets/poin_header_widget.dart';
import '../widgets/poin_main_card_widget.dart';
import '../widgets/poin_activity_list_widget.dart';
import '../widgets/poin_target_card_widget.dart';

class PoinScreen extends StatefulWidget {
  const PoinScreen({super.key});

  @override
  State<PoinScreen> createState() => _PoinScreenState();
}

class _PoinScreenState extends State<PoinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          const MainHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h(context)),
                  const PoinHeaderWidget(),
                  SizedBox(height: 24.h(context)),
                  const PoinMainCardWidget(),
                  SizedBox(height: 24.h(context)),
                  const PoinActivityListWidget(),
                  SizedBox(height: 24.h(context)),
                  const PoinTargetCardWidget(),
                  SizedBox(height: 40.h(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


