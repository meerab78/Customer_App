// import '../auth/address/manage_address_view.dart';
// import '../auth/controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../core/db/shared_pref.dart';
// import '../../core/theme/app_colors.dart';
// import '../../core/theme/fonts_manager.dart';
// import '../../core/theme/textfont_styles.dart';
// import 'widget/profile_option_tile.dart';
//
// import '../base/view.dart';
// import '../auth/change_password/view.dart';
// import 'edit_profile_view.dart';
//
// class ProfileView extends StatefulWidget {
//   const ProfileView({super.key});
//
//   @override
//   State<ProfileView> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileView> {
//   final SharedPrefService _prefs = SharedPrefService();
//
//   String _name = '';
//   String _email = '';
//   String? _dateOfBirth;
//   String? _gender;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }
//
//   Future<void> _loadProfile() async {
//     final name = await _prefs.getName();
//     final email = await _prefs.getEmail();
//     final dateOfBirth = await _prefs.getDateOfBirth();
//     final gender = await _prefs.getGender();
//
//     if (!mounted) return;
//
//     setState(() {
//       _name = name ?? '';
//       _email = email ?? '';
//       _dateOfBirth = dateOfBirth;
//       _gender = gender;
//     });
//   }
//
//   Future<void> _editProfile() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditProfileView(
//           name: _name,
//           dateOfBirth: _dateOfBirth,
//           gender: _gender,
//         ),
//       ),
//     );
//
//     if (result != null) {
//       await _loadProfile();
//     }
//   }
//
//   Future<void> _logout() async {
//     await _prefs.clearAuth();
//     if (!mounted) return;
//
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const BaseView(
//           initialIndex: 0,
//         ),
//       ),
//           (route) => false,
//     );
//   }
//
//   Future<void> _deleteAccount() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete Account'),
//           content: const Text(
//             'Are you sure you want to delete your account?',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirm != true) return;
//
//     final userId = await _prefs.getUserId();
//
//     if (userId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('User ID not found'),
//         ),
//       );
//       return;
//     }
//     final provider = Provider.of<AuthController>(
//       context,
//       listen: false,
//     );
//     final success = await provider.deleteAccount(
//       userId: userId.toString(),
//     );
//     if (!mounted) return;
//     if (success) {
//       await _prefs.clearAuth();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Account deleted successfully'),
//         ),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             provider.errorMessage ?? 'Failed to delete account',
//           ),
//         ),
//       );
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Profile',
//                 style: getExtraBoldStyle(
//                   fontSize: MyFonts.size30,
//                   color: AppColors.text,
//                 ),
//               ),
//
//               const SizedBox(height: 25),
//
//               // Profile Header
//               Center(
//                 child: Column(
//                   children: [
//                     Stack(
//                       children: [
//                         Container(
//                           height: 100,
//                           width: 100,
//                           decoration: BoxDecoration(
//                             color: AppColors.primary.withOpacity(.12),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.person_rounded,
//                             size: 55,
//                             color: AppColors.primary,
//                           ),
//                         ),
//
//                         Positioned(
//                           right: 0,
//                           bottom: 2,
//                           child: GestureDetector(
//                             onTap: _editProfile,
//                             child: Container(
//                               height: 34,
//                               width: 34,
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color: AppColors.background,
//                                   width: 3,
//                                 ),
//                               ),
//                               child: Icon(
//                                 Icons.edit_rounded,
//                                 size: 16,
//                                 color: AppColors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const SizedBox(height: 14),
//
//                     Text(
//                       _name.isEmpty ? 'User' : _name,
//                       style: getExtraBoldStyle(
//                         fontSize: MyFonts.size20,
//                         color: AppColors.text,
//                       ),
//                     ),
//
//                     const SizedBox(height: 4),
//
//                     Text(
//                       _email,
//                       style: getRegularStyle(
//                         fontSize: MyFonts.size13,
//                         color: AppColors.greyText,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//                Text(
//                 'Account',
//                 style: getExtraBoldStyle(
//                   fontSize: MyFonts.size17,
//                   color: AppColors.text,
//                 ),
//               ),
//
//               const SizedBox(height: 15),
//
//               ProfileOptionTile(
//                 title: 'Change Password',
//                 icon: Icons.lock_outline_rounded,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const ChangePasswordView(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 12),
//               ProfileOptionTile(
//                 title: 'Discount Voucher',
//                 icon: Icons.discount_outlined,
//                 onTap: () {
//                   // Discount voucher
//                 },
//               ),
//               const SizedBox(height: 12),
//               ProfileOptionTile(
//                 title: 'Manage Address',
//                 icon: Icons.location_on,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const ManageAddressView(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 12),
//
//               ProfileOptionTile(
//                 title: 'Delete Account',
//                 icon: Icons.delete_outline_rounded,
//                 onTap: _deleteAccount,
//               ),
//               const SizedBox(height: 12),
//
//               ProfileOptionTile(
//                 title: 'Logout',
//                 icon: Icons.logout_rounded,
//                 onTap: _logout,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
import '../auth/address/manage_address_view.dart';
import '../auth/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/db/shared_pref.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import 'widget/profile_option_tile.dart';

import '../base/view.dart';
import '../auth/change_password/view.dart';
import 'edit_profile_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileView> {
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
        builder: (_) => EditProfileView(
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
        builder: (_) => const BaseView(
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
    final provider = Provider.of<AuthController>(
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
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size30,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 22),

              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.16),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: AppColors.white,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 2,
                          child: GestureDetector(
                            onTap: _editProfile,
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black26,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit_rounded,
                                size: 15,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _name.isEmpty ? 'User' : _name,
                      style: getExtraBoldStyle(
                        fontSize: MyFonts.size20,
                        color: AppColors.white,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _email,
                      style: getRegularStyle(
                        fontSize: MyFonts.size13,
                        color: AppColors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Account',
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size17,
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
                      builder: (_) => const ChangePasswordView(),
                    ),
                  );
                },
              ),

              ProfileOptionTile(
                title: 'Discount Voucher',
                icon: Icons.discount_outlined,
                onTap: () {
                  // Discount voucher
                },
              ),

              ProfileOptionTile(
                title: 'Manage Address',
                icon: Icons.location_on,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageAddressView(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              Text(
                'Danger Zone',
                style: getExtraBoldStyle(
                  fontSize: MyFonts.size17,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 15),

              ProfileOptionTile(
                title: 'Delete Account',
                icon: Icons.delete_outline_rounded,
                onTap: _deleteAccount,
              ),

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