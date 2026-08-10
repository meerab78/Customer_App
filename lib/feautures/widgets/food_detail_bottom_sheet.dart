import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/models/menu_model.dart';
import '../../core/theme/app_colors.dart';
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

                  /// Blur
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 2,
                      sigmaY: 2,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(.08),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        height: MediaQuery.of(context).size.height * .72,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                            children: [

                            const SizedBox(height: 10),

                        Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            12,
                            18,
                            10,
                          ),
                          child: Row(
                            children: [

                              const Spacer(),

                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: 38,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                            child: SingleChildScrollView(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 22,
                              ),
                              child: Column(
                                children: [

                              ClipRRect(
                              borderRadius:
                              BorderRadius.circular(
                              20,
                              ),
                              child: (food.image != null &&
                                  food.image!
                                      .isNotEmpty)
                                  ? Image.network(
                                food.imageUrl ?? "",
                                width: 180,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) {
                                  return _placeholder();
                                },
                              )
                                  : _placeholder(),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              food.name ?? "",
                              textAlign: TextAlign.center,
                              style:
                              const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Rs ${food.price}",
                              style:
                              const TextStyle(
                                color:
                                AppColors.primary,
                                fontSize: 22,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            if ((food.description ?? "")
                            .isNotEmpty) ...[
                    const SizedBox(
                    height: 15,
                  ),

                  Text(
                    food.description!,
                    textAlign:
                    TextAlign.center,
                    style:
                    const TextStyle(
                      color: AppColors
                          .greyText,
                      height: 1.5,
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                    AppColors.background,
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: Row(
                    children: [

                      const Text(
                        "Quantity",
                        style: TextStyle(
                          fontWeight:
                          FontWeight
                              .bold,
                          fontSize: 16,
                        ),
                      ),

                      const Spacer(),

                      _circleButton(
                        Icons.remove,
                            () {
                          if (quantity >
                              1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          18,
                        ),
                        child: Text(
                          quantity
                              .toString(),
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ),

                      _circleButton(
                        Icons.add,
                            () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        AppColors.primary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                        ),
                                      ),
                                      onPressed: () {

                                        /// TODO
                                        /// Add to cart

                                      },
                                      child: Text(
                                        "Add To Cart • Rs ${(double.tryParse(food.price ?? "0") ?? 0) * quantity}",
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 25),
                                ],
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

Widget _placeholder() {
  return Container(
    width: 180,
    height: 180,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Icon(
      Icons.fastfood,
      size: 70,
      color: AppColors.primary,
    ),
  );
}

Widget _circleButton(
    IconData icon,
    VoidCallback onTap,
    ) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(50),
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
      ),
    ),
  );
}