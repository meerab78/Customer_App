

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/models/menu_model.dart';
import 'food_detail_content.dart';

void showFoodDetailBottomSheet(
    BuildContext context,
    Menu food,
    ) {
  int quantity = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Stack(
            children: [
// Background blur
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 3,
                  sigmaY: 3,
                ),
                child: Container(
                  color: Colors.black.withOpacity(.10),
                ),
              ),

// Bottom sheet
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight:
                    MediaQuery.of(context).size.height * .72,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),

// Drag handle
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

// Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          10,
                          16,
                          4,
                        ),
                        child: Row(
                          children: [
                            const Spacer(),

                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              borderRadius:
                              BorderRadius.circular(50),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

// Scrollable content
                      Flexible(
                        child: SingleChildScrollView(
                          physics:
                          const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            4,
                            20,
                            18,
                          ),
                          child: FoodDetailContent(
                            food: food,
                            quantity: quantity,
                            onQuantityChanged: (value) {
                              setState(() {
                                quantity = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
