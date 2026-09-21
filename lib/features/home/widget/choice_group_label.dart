import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../model/menu_model.dart';


String choiceGroupHint(ChoiceGroup group) {
  final min = group.minChoices ?? 0;
  final max = group.maxChoices ?? 0;

  if (max <= 0) return 'Choose any';
  if (min == max) return 'Choose $max';
  return 'Choose any $max';
}


bool choiceGroupIsRequired(ChoiceGroup group) => (group.minChoices ?? 0) > 0;

class ChoiceGroupLabel extends StatelessWidget {
  final ChoiceGroup group;

  const ChoiceGroupLabel({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final required = choiceGroupIsRequired(group);
    final color = required ? AppColors.error : AppColors.greyText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          choiceGroupHint(group),
          style: getRegularStyle(
            fontSize: MyFonts.size12,
            color: AppColors.greyText,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            required ? 'Required' : 'Optional',
            style: getBoldStyle(fontSize: MyFonts.size10, color: color),
          ),
        ),
      ],
    );
  }
}