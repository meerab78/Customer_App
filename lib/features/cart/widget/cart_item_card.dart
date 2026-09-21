// import 'package:flutter/material.dart';
// import '../../../core/db/sqflite/model.dart.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/fonts_manager.dart';
// import '../../../core/theme/textfont_styles.dart';
//
// class CartItemCard extends StatelessWidget {
//   final OrderDetails item;
//   final VoidCallback onDelete;
//   final VoidCallback onPlus;
//   final VoidCallback onMinus;
//   final VoidCallback? onTap;
//
//   const CartItemCard({
//     super.key,
//     required this.item,
//     required this.onDelete,
//     required this.onPlus,
//     required this.onMinus,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final price =
//         double.tryParse(item.price ?? '0') ?? 0;
//
//     final quantity = item.quantity ?? 1;
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
//         padding: const EdgeInsets.all(9),
//         decoration: BoxDecoration(
//           color: AppColors.card,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(
//             color: AppColors.borderLight,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.shadow,
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // IMAGE
//                 _foodImage(),
//
//                 const SizedBox(width: 10),
//
//                 // DETAILS
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         crossAxisAlignment:
//                         CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               item.menuName ?? 'Food',
//                               maxLines: 2,
//                               overflow:
//                               TextOverflow.ellipsis,
//                               style: getExtraBoldStyle(
//                                 fontSize: MyFonts.size15,
//                                 color: AppColors.text,
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(width: 5),
//
//                           _deleteButton(),
//                         ],
//                       ),
//
//                       const SizedBox(height: 3),
//
//                       // PRICE
//                       Text(
//                         'Rs ${price.toStringAsFixed(0)}',
//                         style: getExtraBoldStyle(
//                           fontSize: MyFonts.size14,
//                           color: AppColors.primary,
//                         ),
//                       ),
//
//                       // NORMAL VARIATION
//                       if (item.menuVariation != null &&
//                           item.menuVariation!.id != null) ...[
//                         const SizedBox(height: 5),
//                         _smallTag(
//                           item.menuVariation!.name ?? '',
//                         ),
//                       ],
//
//                       // DEAL BADGE
//                       if (item.isDeal) ...[
//                         const SizedBox(height: 5),
//                         _dealBadge(),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//
//             if (item.orderDetailChoice.isNotEmpty)
//               _selectedChoices(),
//
//             if (item.isDeal && item.dealDetails.isNotEmpty)
//               _dealDetails(),
//
//             const SizedBox(height: 8),
//
//             Row(
//               mainAxisAlignment:
//               MainAxisAlignment.spaceBetween,
//               children: [
//                 // QUANTITY
//                 _quantitySelector(quantity),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _foodImage() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(14),
//       child: SizedBox(
//         width: 68,
//         height: 68,
//         child: _placeholder(),
//       ),
//     );
//   }
//
//   Widget _deleteButton() {
//     return InkWell(
//       onTap: onDelete,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         width: 29,
//         height: 29,
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           Icons.delete_outline_rounded,
//           size: 16,
//           color: AppColors.grey500,
//         ),
//       ),
//     );
//   }
//
//   Widget _dealBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 3,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(.08),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.local_offer_outlined,
//             size: 11,
//             color: AppColors.primary,
//           ),
//           const SizedBox(width: 3),
//           Text(
//             'DEAL',
//             style: getBoldStyle(
//               fontSize: MyFonts.size9,
//               color: AppColors.primary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _smallTag(String text) {
//     if (text.isEmpty) {
//       return const SizedBox();
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 7,
//         vertical: 3,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Text(
//         text,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: getMediumStyle(
//           fontSize: MyFonts.size10,
//           color: AppColors.grey500,
//         ),
//       ),
//     );
//   }
//
//   List<MapEntry<String?, List<OrderDetailChoice>>>
//       _groupedChoices(List<OrderDetailChoice> choices) {
//     final grouped = <String, List<OrderDetailChoice>>{};
//     final groupNames = <String, String?>{};
//
//     for (final choice in choices) {
//       final groupId = choice.choiceGroupId ?? '0';
//       grouped.putIfAbsent(groupId, () => []);
//       grouped[groupId]!.add(choice);
//       groupNames[groupId] = choice.choiceGroupName;
//     }
//
//     return grouped.entries.map((entry) {
//       return MapEntry(groupNames[entry.key], entry.value);
//     }).toList();
//   }
//
//   Widget _selectedChoices() {
//     final groups = _groupedChoices(item.orderDetailChoice);
//
//     if (groups.isEmpty) {
//       return const SizedBox();
//     }
//
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 8,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment:
//         CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.tune_rounded,
//                 size: 13,
//                 color: AppColors.primary,
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 'Selected options',
//                 style: getBoldStyle(
//                   fontSize: MyFonts.size10,
//                   color: AppColors.text,
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 4),
//
//           ...groups.expand(
//                 (group) => [
//               Text(
//                 group.key ?? '',
//                 style: getBoldStyle(
//                   fontSize: MyFonts.size10,
//                   color: AppColors.text,
//                 ),
//               ),
//
//               ...group.value.map(
//                     (choice) => _choiceRow(
//                   choice.choiceName ?? '',
//                   choice.price,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _dealDetails() {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 8,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(
//           color: AppColors.borderLight,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment:
//         CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.card_giftcard_outlined,
//                 size: 14,
//                 color: AppColors.primary,
//               ),
//               const SizedBox(width: 5),
//               Text(
//                 'Deal includes',
//                 style: getBoldStyle(
//                   fontSize: MyFonts.size11,
//                   color: AppColors.text,
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 6),
//
//           ...item.dealDetails.map(
//                 (dealItem) => _dealItem(dealItem),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _dealItem(OrderDetails dealItem) {
//     final variation = dealItem.menuVariation;
//     final groups = _groupedChoices(dealItem.orderDetailChoice);
//
//     final hasVariation =
//         variation != null && variation.id != null;
//
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 5),
//       padding: const EdgeInsets.symmetric(
//         horizontal: 8,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.containerColor4,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         crossAxisAlignment:
//         CrossAxisAlignment.start,
//         children: [
//           // DEAL ITEM NAME
//           Row(
//             children: [
//               Container(
//                 width: 5,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//
//               const SizedBox(width: 6),
//
//               Expanded(
//                 child: Text(
//                   dealItem.menuName ?? 'Item',
//                   maxLines: 1,
//                   overflow:
//                   TextOverflow.ellipsis,
//                   style: getBoldStyle(
//                     fontSize: MyFonts.size11,
//                     color: AppColors.text,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           // VARIATION
//           if (hasVariation) ...[
//             const SizedBox(height: 3),
//
//             Padding(
//               padding:
//               const EdgeInsets.only(left: 11),
//               child: Text(
//                 variation.name ?? '',
//                 style: getMediumStyle(
//                   fontSize: MyFonts.size10,
//                   color: AppColors.grey500,
//                 ),
//               ),
//             ),
//           ],
//
//           // CHOICES
//           if (groups.isNotEmpty) ...[
//             const SizedBox(height: 3),
//
//             Padding(
//               padding:
//               const EdgeInsets.only(left: 11),
//               child: Column(
//                 crossAxisAlignment:
//                 CrossAxisAlignment.start,
//                 children: groups.expand(
//                       (group) => [
//                     Text(
//                       group.key ?? '',
//                       style: getBoldStyle(
//                         fontSize: MyFonts.size10,
//                         color: AppColors.text,
//                       ),
//                     ),
//
//                     ...group.value.map(
//                           (choice) => _choiceRow(
//                         choice.choiceName ?? '',
//                         choice.price,
//                         compact: true,
//                       ),
//                     ),
//                   ],
//                 ).toList(),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _choiceRow(
//       String name,
//       String? price, {
//         bool compact = false,
//       }) {
//     final hasPrice =
//         price != null && price.isNotEmpty;
//
//     return Padding(
//       padding: const EdgeInsets.only(
//         bottom: 1,
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.check_rounded,
//             size: compact ? 11 : 12,
//             color: AppColors.primary,
//           ),
//
//           const SizedBox(width: 3),
//
//           Expanded(
//             child: Text(
//               name,
//               maxLines: 1,
//               overflow:
//               TextOverflow.ellipsis,
//               style: getRegularStyle(
//                 fontSize: compact
//                     ? MyFonts.size9
//                     : MyFonts.size10,
//                 color: AppColors.grey500,
//               ),
//             ),
//           ),
//
//           if (hasPrice)
//             Text(
//               '(+Rs $price)',
//               style: getMediumStyle(
//                 fontSize: compact
//                     ? MyFonts.size9
//                     : MyFonts.size10,
//                 color: AppColors.grey500,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _quantitySelector(int quantity) {
//     return Container(
//       height: 34,
//       padding: const EdgeInsets.symmetric(
//         horizontal: 2,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           _quantityButton(
//             Icons.remove_rounded,
//             onMinus,
//           ),
//           Padding(
//             padding:
//             const EdgeInsets.symmetric(
//               horizontal: 9,
//             ),
//             child: Text(
//               '$quantity',
//               style: getBoldStyle(
//                 fontSize: MyFonts.size12,
//                 color: AppColors.text,
//               ),
//             ),
//           ),
//
//           _quantityButton(
//             Icons.add_rounded,
//             onPlus,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _quantityButton(
//       IconData icon,
//       VoidCallback onTap,
//       ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: SizedBox(
//         width: 27,
//         height: 30,
//         child: Icon(
//           icon,
//           size: 14,
//           color: AppColors.text,
//         ),
//       ),
//     );
//   }
//
//   Widget _placeholder() {
//     return Container(
//       color: AppColors.containerColor4,
//       child: Icon(
//         item.isDeal
//             ? Icons.card_giftcard_outlined
//             : Icons.fastfood_rounded,
//         color: AppColors.primary,
//         size: 27,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../../../core/db/sqflite/model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class CartItemCard extends StatefulWidget {
  final OrderDetails item;
  final VoidCallback onDelete;
  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final VoidCallback? onTap;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onPlus,
    required this.onMinus,
    this.onTap,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final price = double.tryParse(widget.item.price ?? '0') ?? 0;
    final totalPrice = price * (widget.item.quantity ?? 1);
    final quantity = widget.item.quantity ?? 1;

    final allDetails = _getAllDetailsWidgets();
    final bool hasDetails = allDetails.isNotEmpty;
    final bool needsExpansion = allDetails.length > 2;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderLight.withOpacity(0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LEFT ACCENT BAR
                Container(
                  width: 3.5,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(9.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COLLAPSED VIEW
                        if (!_isExpanded)
                          _buildCollapsedLayout(
                            quantity,
                            totalPrice,
                            allDetails,
                            needsExpansion,
                          )
                        // EXPANDED VIEW
                        else
                          _buildExpandedLayout(
                            quantity,
                            totalPrice,
                            allDetails,
                          ),

                        // TOGGLE BUTTON (Sirf tab jab total details > 2 hon)
                        if (needsExpansion) ...[
                          const SizedBox(height: 2),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  size: 15,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _isExpanded ? 'Show less' : 'Show more',
                                  style: getMediumStyle(
                                    fontSize: MyFonts.size10,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // COLLAPSED STATE
  Widget _buildCollapsedLayout(
      int quantity,
      double totalPrice,
      List<Widget> details,
      bool needsExpansion,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _foodImage(width: 60, height: 60),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.menuName ?? 'Food Item',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: getBoldStyle(
                      fontSize: MyFonts.size14,
                      color: AppColors.text,
                    ),
                  ),

                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    ...details.take(2),
                    // Dots sirf tabhi render hongi jab total details > 2 hon
                    if (needsExpansion)
                      Text(
                        '...',
                        style: getRegularStyle(
                          fontSize: MyFonts.size10,
                          color: AppColors.greyText,
                        ),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 6),

            _quantityControls(quantity),
          ],
        ),

        const SizedBox(height: 4),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'PKR ${totalPrice.toStringAsFixed(2)}',
            style: getBoldStyle(
              fontSize: MyFonts.size13,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  // EXPANDED STATE
  Widget _buildExpandedLayout(
      int quantity,
      double totalPrice,
      List<Widget> details,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.item.menuName ?? 'Food Item',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: getBoldStyle(
                  fontSize: MyFonts.size14,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _quantityControls(quantity),
          ],
        ),

        const SizedBox(height: 4),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: details,
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _foodImage(width: 75, height: 58),
                const SizedBox(height: 8),
                Text(
                  'PKR ${totalPrice.toStringAsFixed(2)}',
                  style: getBoldStyle(
                    fontSize: MyFonts.size13,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _foodImage({required double width, required double height}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          color: AppColors.containerColor4,
          child: Icon(
            widget.item.isDeal
                ? Icons.card_giftcard_outlined
                : Icons.fastfood_rounded,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _quantityControls(int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: quantity == 1 ? widget.onDelete : widget.onMinus,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: quantity == 1 ? Colors.redAccent : AppColors.card,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                quantity == 1
                    ? Icons.delete_outline_rounded
                    : Icons.remove_rounded,
                size: 14,
                color: quantity == 1 ? Colors.white : AppColors.text,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$quantity',
              style: getBoldStyle(
                fontSize: MyFonts.size12,
                color: AppColors.text,
              ),
            ),
          ),
          InkWell(
            onTap: widget.onPlus,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(6),
              ),
              child:  Icon(
                Icons.add_rounded,
                size: 14,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generates flat list of details for easy calculation
  List<Widget> _getAllDetailsWidgets() {
    final List<Widget> list = [];

    if (widget.item.isDeal && widget.item.dealDetails.isNotEmpty) {
      for (var dealItem in widget.item.dealDetails) {
        list.add(
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              dealItem.menuName ?? 'Item',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getBoldStyle(
                fontSize: MyFonts.size12,
                color: AppColors.text,
              ),
            ),
          ),
        );

        if (dealItem.menuVariation != null &&
            dealItem.menuVariation!.name != null) {
          list.add(
            Text(
              dealItem.menuVariation!.name!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getRegularStyle(
                fontSize: MyFonts.size11,
                color: AppColors.greyText,
              ),
            ),
          );
        }

        for (var choice in dealItem.orderDetailChoice) {
          if (choice.choiceName != null && choice.choiceName!.isNotEmpty) {
            list.add(
              Text(
                choice.choiceName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getRegularStyle(
                  fontSize: MyFonts.size11,
                  color: AppColors.greyText,
                ),
              ),
            );
          }
        }
      }
    } else {
      if (widget.item.menuVariation != null &&
          widget.item.menuVariation!.name != null) {
        list.add(
          Text(
            widget.item.menuVariation!.name!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: getRegularStyle(
              fontSize: MyFonts.size11,
              color: AppColors.greyText,
            ),
          ),
        );
      }

      for (var choice in widget.item.orderDetailChoice) {
        if (choice.choiceName != null && choice.choiceName!.isNotEmpty) {
          list.add(
            Text(
              choice.choiceName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: getRegularStyle(
                fontSize: MyFonts.size11,
                color: AppColors.greyText,
              ),
            ),
          );
        }
      }
    }

    return list;
  }
}