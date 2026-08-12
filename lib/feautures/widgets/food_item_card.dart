
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 160,
        height: 205,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: imageUrl.isEmpty
                      ? Container(
                    width: double.infinity,
                    height: 110,
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.fastfood_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  )
                      : Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        width: double.infinity,
                        height: 110,
                        color: Colors.grey.shade100,
                        child:  Icon(
                          Icons.fastfood_rounded,
                          size: 42,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),

                // Add Button
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration:  BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Food Information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  8,
                  10,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(height: 3),

                    // Description
                    if ((description ?? "").isNotEmpty)
                      Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:  TextStyle(
                          fontSize: 11,
                          color: AppColors.greyText,
                          height: 1.2,
                        ),
                      ),

                    const Spacer(),

                    // Price
                    Text(
                      "Rs $price",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}