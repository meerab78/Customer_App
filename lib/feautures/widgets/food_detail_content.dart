
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../core/models/menu_model.dart';
import '../../core/provider/cart_provider.dart';
import '../../core/theme/app_colors.dart';

class FoodDetailContent extends StatelessWidget {
  final Menu food;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const FoodDetailContent({
    super.key,
    required this.food,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final price =
        double.tryParse(food.price ?? "0") ?? 0;

    final total = price * quantity;

    return Column(
      children: [
// Food image
        FoodImage(
          imageUrl: food.imageUrl ?? "",
          hasImage:
          food.image != null &&
              food.image!.isNotEmpty,
        ),

        const SizedBox(height: 16),

// Name + Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                food.name ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Rs ${food.price}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),

// Description
        if ((food.description ?? "").trim().isNotEmpty) ...[
          const SizedBox(height: 9),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              food.description!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppColors.greyText,
              ),
            ),
          ),
        ],

        const SizedBox(height: 18),

// Quantity + Add To Cart
        Container(
          height: 54,
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: [
// Minus
              QuantityButton(
                icon: Icons.remove_rounded,
                onTap: () {
                  if (quantity > 1) {
                    onQuantityChanged(quantity - 1);
                  }
                },
              ),

// Quantity
              SizedBox(
                width: 34,
                child: Text(
                  quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

// Plus
              QuantityButton(
                icon: Icons.add_rounded,
                onTap: () {
                  onQuantityChanged(quantity + 1);
                },
              ),

              const SizedBox(width: 8),

// Add to cart
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: () {
                      context.read<CartProvider>().addToCart(
                        food,
                        quantity,
                      );

                      Navigator.pop(context);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Add To Cart • Rs $total",
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class FoodImage extends StatelessWidget {
  final String imageUrl;
  final bool hasImage;

  const FoodImage({
    super.key,
    required this.imageUrl,
    required this.hasImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      height: 165,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: hasImage
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const FoodPlaceholder();
          },
        )
            : const FoodPlaceholder(),
      ),
    );
  }
}


class FoodPlaceholder extends StatelessWidget {
  const FoodPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child:  Icon(
        Icons.fastfood_rounded,
        size: 55,
        color: AppColors.primary,
      ),
    );
  }
}


class QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QuantityButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Icon(
          icon,
          size: 17,
        ),
      ),
    );
  }
}

