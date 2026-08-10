import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
class FoodItemCard extends StatelessWidget {
  final String name;
  final String? description;
  final String price;
  final String imageUrl;
  final VoidCallback? onTap;
  const FoodItemCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            /// LEFT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if ((description ?? "").isNotEmpty)
                    Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.greyText,
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    "Rs $price",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            /// IMAGE
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.isEmpty
                        ? Container(
                      width: 95,
                      height: 95,
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.fastfood,
                        color: AppColors.primary,
                        size: 35,
                      ),
                    )
                        : Image.network(
                      imageUrl,
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          width: 95,
                          height: 95,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.fastfood,
                            color: AppColors.primary,
                            size: 35,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  height: 32,
                  width: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}