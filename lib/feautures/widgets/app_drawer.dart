import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(.1),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.primary,
                size: 38,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "QA Restaurant",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Delicious Food Delivered",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            _tile(
              Icons.home_outlined,
              "Home",
                  () {
                Navigator.pop(context);
              },
            ),
            _tile(
              Icons.receipt_long_outlined,
              "My Orders",
                  () {},
            ),
            _tile(
              Icons.favorite_border,
              "Favorites",
                  () {},
            ),
            _tile(
              Icons.location_on_outlined,
              "Change Address",
                  () {},
            ),
            _tile(
              Icons.settings_outlined,
              "Settings",
                  () {},
            ),
            const Spacer(),
            const Divider(),
            _tile(
              Icons.logout,
              "Logout",
                  () {},
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _tile(
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}