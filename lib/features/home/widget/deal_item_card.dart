//
// import 'package:flutter/material.dart';
//
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/fonts_manager.dart';
// import '../../../core/theme/textfont_styles.dart';
// import '../model/menu_model.dart';
// import 'variation_selector.dart';
//
// class DealItemCard extends StatefulWidget {
//   final Menu item;
//   final ValueChanged<Menu>? onItemUpdated;
//   final ValueChanged<bool>? onCompletionChanged;
//
//   const DealItemCard({
//     super.key,
//     required this.item,
//     this.onItemUpdated,
//     this.onCompletionChanged,
//   });
//
//   @override
//   State<DealItemCard> createState() => _DealItemCardState();
// }
//
// class _DealItemCardState extends State<DealItemCard> {
//   bool isExpanded = false;
//   MenuVariation? selectedVariation;
//   final Map<int, List<MenuVariation>> selectedChoices = {};
//   late Menu _originalItem;
//
//   @override
//   void initState() {
//     super.initState();
//     _originalItem = widget.item;
//     _initializeExistingSelection();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       if (hasCustomization) {
//         widget.onItemUpdated?.call(_buildUpdatedItem());
//       }
//       widget.onCompletionChanged?.call(!hasCustomization || isValid);
//     });
//   }
//
//   @override
//   void didUpdateWidget(covariant DealItemCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (oldWidget.item.id != widget.item.id) {
//       _originalItem = widget.item;
//       selectedVariation = null;
//       selectedChoices.clear();
//       _initializeExistingSelection();
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (!mounted) return;
//         if (hasCustomization) {
//           widget.onItemUpdated?.call(_buildUpdatedItem());
//         }
//         widget.onCompletionChanged?.call(!hasCustomization || isValid);
//       });
//     }
//   }
//
//   void _initializeExistingSelection() {
//     if (_originalItem.menuVariation != null) {
//       final existingVariation = _originalItem.menuVariation!;
//       for (final variation in _originalItem.menuVariations) {
//         if (variation.id == existingVariation.id) {
//           selectedVariation = variation;
//           break;
//         }
//       }
//       selectedVariation ??= existingVariation;
//     }
//   }
//
//   void _loadSelectedChoicesFromGroups(List<ChoiceGroup> groups) {
//     for (final group in groups) {
//       if (group.id == null) continue;
//       if (group.choices.isNotEmpty) {
//         selectedChoices[group.id!] = List<MenuVariation>.from(group.choices);
//       }
//     }
//   }
//
//   double get finalPrice {
//     double total = 0;
//     for (final choices in selectedChoices.values) {
//       for (final choice in choices) {
//         total += double.tryParse(choice.price ?? '0') ?? 0;
//       }
//     }
//     return total;
//   }
//
//   bool get hasCustomization {
//     return _originalItem.menuVariations.isNotEmpty ||
//         _originalItem.choiceGroup.isNotEmpty ||
//         _originalItem.menuVariation != null;
//   }
//
//   List<ChoiceGroup> get choiceGroups {
//     final groups = <ChoiceGroup>[];
//     groups.addAll(_originalItem.choiceGroup);
//     if (selectedVariation != null) {
//       groups.addAll(selectedVariation!.choiceGroups);
//     } else if (_originalItem.menuVariation != null) {
//       groups.addAll(_originalItem.menuVariation!.choiceGroups);
//     }
//     return groups;
//   }
//
//   bool get isValid {
//     for (final group in choiceGroups) {
//       final groupId = group.id;
//       if (groupId == null) continue;
//       final selectedCount = selectedChoices[groupId]?.length ?? 0;
//       final minChoices = group.minChoices ?? 0;
//       final maxChoices = group.maxChoices ?? 0;
//       if (minChoices == 0) {
//         if (maxChoices > 0 && selectedCount > maxChoices) return false;
//         continue;
//       }
//       if (selectedCount < minChoices) return false;
//       if (maxChoices > 0 && selectedCount > maxChoices) return false;
//     }
//     return true;
//   }
//
//   void _selectVariation(MenuVariation variation) {
//     setState(() {
//       selectedVariation = variation;
//       selectedChoices.clear();
//     });
//   }
//
//   void _toggleChoice(ChoiceGroup group, MenuVariation choice) {
//     final groupId = group.id;
//     if (groupId == null) return;
//
//     final selected = List<MenuVariation>.from(selectedChoices[groupId] ?? []);
//     final alreadySelected = selected.any((item) => item.id == choice.id);
//
//     if (alreadySelected) {
//       selected.removeWhere((item) => item.id == choice.id);
//     } else {
//       final maxChoices = group.maxChoices ?? 0;
//       if (maxChoices > 0 && selected.length >= maxChoices) return;
//       selected.add(choice);
//     }
//
//     setState(() {
//       selectedChoices[groupId] = selected;
//     });
//   }
//
//   void _toggleExpanded() {
//     if (!hasCustomization) return;
//     setState(() {
//       isExpanded = !isExpanded;
//     });
//   }
//
//   Menu _buildUpdatedItem() {
//     final directGroups = _originalItem.choiceGroup.map((group) {
//       final selected = selectedChoices[group.id] ?? [];
//       return group.copyWith(choices: selected);
//     }).toList();
//
//     MenuVariation? finalVariation;
//     if (selectedVariation != null) {
//       final variationGroups = selectedVariation!.choiceGroups.map((group) {
//         final selected = selectedChoices[group.id] ?? [];
//         return group.copyWith(choices: selected);
//       }).toList();
//
//       finalVariation = selectedVariation!.copyWith(
//         choiceGroups: variationGroups,
//       );
//     }
//
//     return _originalItem.copyWith(
//       menuVariation: finalVariation,
//       choiceGroup: directGroups,
//     );
//   }
//
//   Widget _image() {
//     final url = widget.item.imageUrl ?? '';
//
//     if (url.isEmpty) {
//       return _placeholder();
//     }
//
//     return Image.network(
//       url,
//       fit: BoxFit.cover,
//       errorBuilder: (_, __, ___) => _placeholder(),
//     );
//   }
//
//   Widget _placeholder() {
//     return Container(
//       color: AppColors.tertiary.withOpacity(0.1),
//       child: Icon(
//         Icons.fastfood_outlined,
//         color: AppColors.tertiary,
//         size: 24,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isReady = !hasCustomization || isValid;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isExpanded ? AppColors.primary : AppColors.borderColorGrey,
//           width: isExpanded ? 1.4 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.softShadow04,
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ITEM HEADER
//           InkWell(
//             onTap: _toggleExpanded,
//             borderRadius: BorderRadius.circular(16),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // COMPACT IMAGE SIZE (56x56 instead of 75x75)
//                   Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: SizedBox(
//                           width: 56,
//                           height: 56,
//                           child: _image(),
//                         ),
//                       ),
//                       Positioned(
//                         right: -3,
//                         top: -3,
//                         child: Container(
//                           padding: const EdgeInsets.all(3),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: isReady
//                                 ? AppColors.success
//                                 : AppColors.tertiary,
//                             border: Border.all(
//                               color: AppColors.card,
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Icon(
//                             isReady
//                                 ? Icons.check_rounded
//                                 : Icons.edit_rounded,
//                             size: 10,
//                             color: AppColors.white,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(width: 12),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 widget.item.name ?? 'Item',
//                                 style: getBoldStyle(
//                                   fontSize: MyFonts.size15,
//                                   color: AppColors.text,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColors.tertiary.withOpacity(0.12),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Text(
//                                 'x${widget.item.quantity ?? 1}',
//                                 style: getBoldStyle(
//                                   fontSize: MyFonts.size12,
//                                   color: AppColors.tertiary,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         if (hasCustomization && selectedVariation != null) ...[
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.sell_outlined,
//                                 size: 11,
//                                 color: AppColors.grey500,
//                               ),
//                               const SizedBox(width: 4),
//                               Flexible(
//                                 child: Text(
//                                   '${selectedVariation!.name ?? ''} comes with this deal',
//                                   overflow: TextOverflow.ellipsis,
//                                   style: getRegularStyle(
//                                     fontSize: MyFonts.size12,
//                                     color: AppColors.grey500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//
//                         // SELECTED CHOICES LIST
//                         ...selectedChoices.entries.expand(
//                               (entry) => entry.value.map(
//                                 (choice) => Padding(
//                               padding: const EdgeInsets.only(top: 2),
//                               child: Text(
//                                 '• ${choice.name ?? ''}',
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: getRegularStyle(
//                                   fontSize: MyFonts.size12,
//                                   color: AppColors.grey500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         if (hasCustomization) ...[
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Text(
//                                 isExpanded
//                                     ? 'Close customization'
//                                     : (isReady
//                                     ? 'Tap to edit'
//                                     : 'Tap to customize'),
//                                 style: getRegularStyle(
//                                   fontSize: MyFonts.size12,
//                                   color: AppColors.primary,
//                                 ),
//                               ),
//                               const SizedBox(width: 3),
//                               AnimatedRotation(
//                                 turns: isExpanded ? 0.5 : 0,
//                                 duration: const Duration(milliseconds: 200),
//                                 child: Icon(
//                                   Icons.keyboard_arrow_down,
//                                   size: 15,
//                                   color: AppColors.primary,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // EXPANDED CUSTOMIZATION SECTION
//           AnimatedCrossFade(
//             duration: const Duration(milliseconds: 220),
//             crossFadeState: (isExpanded && hasCustomization)
//                 ? CrossFadeState.showFirst
//                 : CrossFadeState.showSecond,
//             firstChild: Padding(
//               padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
//               child: Column(
//                 children: [
//                   Divider(color: AppColors.divider),
//                   const SizedBox(height: 6),
//                   VariationSelector(
//                     variations: _originalItem.menuVariations,
//                     choiceGroups: choiceGroups,
//                     selectedVariation: selectedVariation,
//                     selectedChoices: selectedChoices,
//                     onVariationSelected: _selectVariation,
//                     onChoiceSelected: _toggleChoice,
//                   ),
//                   const SizedBox(height: 8),
//
//                   // DONE BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     height: 44,
//                     child: ElevatedButton(
//                       onPressed: isValid
//                           ? () {
//                         final updatedItem = _buildUpdatedItem();
//                         widget.onItemUpdated?.call(updatedItem);
//                         widget.onCompletionChanged?.call(true);
//                         setState(() {
//                           isExpanded = false;
//                         });
//                       }
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         disabledBackgroundColor: AppColors.grey300,
//                         foregroundColor: AppColors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(
//                         isValid
//                             ? 'Done - Rs ${finalPrice.toStringAsFixed(0)}'
//                             : 'Complete Selection',
//                         style: getBoldStyle(
//                           fontSize: MyFonts.size14,
//                           color: AppColors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             secondChild: const SizedBox(
//               width: double.infinity,
//               height: 0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../model/menu_model.dart';

class DealItemCard extends StatefulWidget {
  final Menu item;
  final ValueChanged<Menu>? onItemUpdated;
  final ValueChanged<bool>? onCompletionChanged;

  const DealItemCard({
    super.key,
    required this.item,
    this.onItemUpdated,
    this.onCompletionChanged,
  });

  @override
  State<DealItemCard> createState() => _DealItemCardState();
}

class _DealItemCardState extends State<DealItemCard> {
  MenuVariation? selectedVariation;
  final Map<int, List<MenuVariation>> selectedChoices = {};
  late Menu _originalItem;

  @override
  void initState() {
    super.initState();
    _originalItem = widget.item;
    _initializeExistingSelection();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (hasCustomization) {
        widget.onItemUpdated?.call(_buildUpdatedItem());
      }
      widget.onCompletionChanged?.call(!hasCustomization || isValid);
    });
  }

  void _initializeExistingSelection() {
    if (_originalItem.menuVariations.isNotEmpty) {
      if (_originalItem.menuVariation != null) {
        final existingVariation = _originalItem.menuVariation!;
        for (final variation in _originalItem.menuVariations) {
          if (variation.id == existingVariation.id) {
            selectedVariation = variation;
            break;
          }
        }
      }
      selectedVariation ??= _originalItem.menuVariations.first;
    } else if (_originalItem.menuVariation != null) {
      selectedVariation = _originalItem.menuVariation;
    }
  }

  bool get hasCustomization {
    return _originalItem.menuVariations.isNotEmpty ||
        _originalItem.choiceGroup.isNotEmpty ||
        _originalItem.menuVariation != null;
  }

  List<ChoiceGroup> get choiceGroups {
    final groups = <ChoiceGroup>[];
    groups.addAll(_originalItem.choiceGroup);

    if (selectedVariation != null) {
      groups.addAll(selectedVariation!.choiceGroups);
    } else if (_originalItem.menuVariation != null) {
      groups.addAll(_originalItem.menuVariation!.choiceGroups);
    }
    return groups;
  }

  bool get isValid {
    for (final group in choiceGroups) {
      final groupId = group.id;
      if (groupId == null) continue;
      final selectedCount = selectedChoices[groupId]?.length ?? 0;
      final minChoices = group.minChoices ?? 0;
      final maxChoices = group.maxChoices ?? 0;

      if (minChoices == 0) {
        if (maxChoices > 0 && selectedCount > maxChoices) return false;
        continue;
      }
      if (selectedCount < minChoices) return false;
      if (maxChoices > 0 && selectedCount > maxChoices) return false;
    }
    return true;
  }

  void _selectVariation(MenuVariation variation) {
    setState(() {
      selectedVariation = variation;
      selectedChoices.clear();
    });
    widget.onItemUpdated?.call(_buildUpdatedItem());
    widget.onCompletionChanged?.call(!hasCustomization || isValid);
  }

  void _toggleChoice(ChoiceGroup group, MenuVariation choice) {
    final groupId = group.id;
    if (groupId == null) return;

    final selected = List<MenuVariation>.from(selectedChoices[groupId] ?? []);
    final alreadySelected = selected.any((item) => item.id == choice.id);

    if (alreadySelected) {
      selected.removeWhere((item) => item.id == choice.id);
    } else {
      final maxChoices = group.maxChoices ?? 0;
      if (maxChoices > 0 && selected.length >= maxChoices) return;
      selected.add(choice);
    }

    setState(() {
      selectedChoices[groupId] = selected;
    });

    widget.onItemUpdated?.call(_buildUpdatedItem());
    widget.onCompletionChanged?.call(!hasCustomization || isValid);
  }

  Menu _buildUpdatedItem() {
    final directGroups = _originalItem.choiceGroup.map((group) {
      final selected = selectedChoices[group.id] ?? [];
      return group.copyWith(choices: selected);
    }).toList();

    MenuVariation? finalVariation;
    if (selectedVariation != null) {
      final variationGroups = selectedVariation!.choiceGroups.map((group) {
        final selected = selectedChoices[group.id] ?? [];
        return group.copyWith(choices: selected);
      }).toList();

      finalVariation = selectedVariation!.copyWith(
        choiceGroups: variationGroups,
      );
    }

    return _originalItem.copyWith(
      menuVariation: finalVariation,
      choiceGroup: directGroups,
    );
  }

  String _getItemSubtitle() {
    if (selectedVariation != null && selectedVariation!.name != null) {
      return selectedVariation!.name!;
    }
    if (_originalItem.menuVariation != null && _originalItem.menuVariation!.name != null) {
      return _originalItem.menuVariation!.name!;
    }
    if (_originalItem.description != null && _originalItem.description!.isNotEmpty) {
      return _originalItem.description!;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final String subtitle = _getItemSubtitle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FIXED UI: Item Name Grey Header Box (Theme-aware)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.containerColor4, // Light me soft grey, Dark me dark grey surface
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left Maroon Accent Line
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Quantity Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.item.quantity ?? 1}x',
                    style: getBoldStyle(
                      fontSize: MyFonts.size12,
                      color: AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Text Name & Subtitle
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${widget.item.name ?? 'Item'} ',
                            style: getBoldStyle(
                              fontSize: MyFonts.size13,
                              color: AppColors.text,
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            TextSpan(
                              text: '($subtitle)',
                              style: getRegularStyle(
                                fontSize: MyFonts.size13,
                                color: AppColors.greyText,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // FIXED UI: Choice groups inside Deal Item Card
        if (hasCustomization)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: choiceGroups.map((group) {
                final groupId = group.id ?? 0;
                final currentChoices = selectedChoices[groupId] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      group.name ?? 'Options',
                      style: getBoldStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.maxChoices != null && group.maxChoices! > 1
                          ? 'Select 0-${group.maxChoices}'
                          : 'Select 0-1',
                      style: getRegularStyle(
                        fontSize: MyFonts.size11,
                        color: AppColors.greyText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: group.choices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final choice = group.choices[index];
                        final isSelected = currentChoices
                            .any((item) => item.id == choice.id);
                        final isRadio = group.maxChoices == 1;

                        return InkWell(
                          onTap: () => _toggleChoice(group, choice),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.card, // Pure Dark surface in dark mode
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isRadio
                                      ? (isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off)
                                      : (isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank),
                                  size: 20,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.grey400,
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    choice.name ?? '',
                                    style: getBoldStyle(
                                      fontSize: MyFonts.size13,
                                      color: AppColors.text, // Proper white text in Dark mode
                                    ),
                                  ),
                                ),

                                Text(
                                  '+ Rs ${(double.tryParse(choice.price ?? '0')?.toStringAsFixed(2) ?? '0.00')}',
                                  style: getBoldStyle(
                                    fontSize: MyFonts.size12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}