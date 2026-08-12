import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/provider/auth_provider.dart' show AuthProvider;
import '../../../../core/services/share_prefernces.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/profile_option_tile.dart';

import '../../home/main_navigation_screen.dart';
import '../Change Password/change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SharedPrefService _prefs = SharedPrefService();

  String _name = '';
  String _email = '';
  String? _dateOfBirth;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await _prefs.getName();
    final email = await _prefs.getEmail();
    final dateOfBirth = await _prefs.getDateOfBirth();
    final gender = await _prefs.getGender();

    if (!mounted) return;

    setState(() {
      _name = name ?? '';
      _email = email ?? '';
      _dateOfBirth = dateOfBirth;
      _gender = gender;
    });
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: _name,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
        ),
      ),
    );

    if (result != null) {
      await _loadProfile();
    }
  }

  Future<void> _logout() async {
    await _prefs.clearAuth();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(
          initialIndex: 0,
        ),
      ),
          (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final userId = await _prefs.getUserId();

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID not found'),
        ),
      );
      return;
    }
    final provider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    final success = await provider.deleteAccount(
      userId: userId.toString(),
    );
    if (!mounted) return;
    if (success) {
      await _prefs.clearAuth();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account deleted successfully'),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to delete account',
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 25),

              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 55,
                            color: AppColors.primary,
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 2,
                          child: GestureDetector(
                            onTap: _editProfile,
                            child: Container(
                              height: 34,
                              width: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      _name.isEmpty ? 'User' : _name,
                      style:  TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _email,
                      style:  TextStyle(
                        fontSize: 13,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

               Text(
                'Account',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 15),

              ProfileOptionTile(
                title: 'Change Password',
                icon: Icons.lock_outline_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              ProfileOptionTile(
                title: 'Discount Voucher',
                icon: Icons.discount_outlined,
                onTap: () {
                  // Discount voucher
                },
              ),

              const SizedBox(height: 12),

              ProfileOptionTile(
                title: 'Delete Account',
                icon: Icons.delete_outline_rounded,
                onTap: _deleteAccount,
              ),
              const SizedBox(height: 12),

              ProfileOptionTile(
                title: 'Logout',
                icon: Icons.logout_rounded,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}