
import 'package:customer_app/features/profile/widget/stat_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constant/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/page_transitions.dart';
import '../auth/address/manage_address_view.dart';
import '../auth/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/db/shared_pref.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../auth/splash/view.dart';
import '../cart/controller.dart' show CartController;
import '../home/controller.dart';
import '../home/widget/order_type_bottom_sheet.dart';
import 'About US/view.dart';
import 'Loyalty_transactions/controller.dart';
import 'Loyalty_transactions/loyalty_history_view.dart';
import 'Wallet/controller.dart';
import 'Wallet/wallet_history_view.dart';
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
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();

    if (AppConstants.enableLoyaltySystem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LoyaltyController>().loadLoyaltyData();
        context.read<WalletController>().loadWalletData();
      });
    }
  }

  Future<void> _loadProfile() async {
    final name = await _prefs.getName();
    final email = await _prefs.getEmail();
    final dateOfBirth = await _prefs.getDateOfBirth();
    final gender = await _prefs.getGender();
    final isGuest = await _prefs.getIsGuest();

    if (!mounted) return;

    setState(() {
      _name = name ?? '';
      _email = email ?? '';
      _dateOfBirth = dateOfBirth;
      _gender = gender;
      _isGuest = isGuest;
    });
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      PageTransitions.slideFromRight(
        EditProfileView(
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

  Future<void> _performLogout() async {
    await _prefs.clearAuth();
    if (!mounted) return;

    final cart = context.read<CartController>();
    await cart.clearCart();
    cart.resetGuestUser();

    Navigator.pushAndRemoveUntil(
      context,
      PageTransitions.slideFromRight(
        const BaseView(
          initialIndex: 0,
        ),
      ),
          (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 26,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Logout?',
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: MyFonts.size18,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          textAlign: TextAlign.center,
          style: getRegularStyle(
            fontSize: MyFonts.size13,
            color: AppColors.greyText,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: getSemiBoldStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.greyText,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: getSemiBoldStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _performLogout();
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 27,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Delete Account?',
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontSize: MyFonts.size18,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete your account?',
          textAlign: TextAlign.center,
          style: getRegularStyle(
            fontSize: MyFonts.size13,
            color: AppColors.greyText,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: getSemiBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.greyText,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Delete',
                  style: getSemiBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
  Future<void> _launchSocialUrl(String type) async {
    final data = context.read<HomeController>().menuModel?.data;
    if (data == null) return;

    String? url;

    switch (type) {
      case 'facebook':
        url = data.facebookProfileUrl;
        break;
      case 'instagram':
        url = data.instagramProfileUrl;
        break;
      case 'tiktok':
        url = data.tiktokProfileUrl;
        break;
      case 'youtube':
        url = data.youtubeProfileUrl;
        break;
      case 'twitter':
        url = data.xProfileUrl;
        break;
      case 'linkedin':
        url = data.linkedinProfileUrl;
        break;
      default:
        return;
    }

    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService.instance,
      builder: (context, _) {
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
                  // Profile Header Section
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 92,
                              width: 92,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.20),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),

                            Positioned(
                              right: 0,
                              bottom: 2,
                              child: GestureDetector(
                                onTap: _editProfile,
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.card,
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
                                    size: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isGuest ? 'Guest' : (_name.isEmpty ? 'User' : _name),
                                style: getExtraBoldStyle(
                                  fontSize: MyFonts.size20,
                                  color: AppColors.text,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isGuest
                                          ? Icons.login_rounded
                                          : Icons.email_outlined,
                                      size: 13,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        _isGuest
                                            ? 'Login to view your profile'
                                            : _email,
                                        style: getSemiBoldStyle(
                                          fontSize: MyFonts.size12,
                                          color: AppColors.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profile Header Card
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.symmetric(
                  //     vertical: 28,
                  //     horizontal: 16,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [
                  //         AppColors.primary,
                  //         AppColors.secondary,
                  //       ],
                  //       begin: Alignment.topLeft,
                  //       end: Alignment.bottomRight,
                  //     ),
                  //     borderRadius: BorderRadius.circular(26),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: AppColors.primary.withOpacity(0.28),
                  //         blurRadius: 22,
                  //         offset: const Offset(0, 10),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       Stack(
                  //         children: [
                  //           Container(
                  //             height: 100,
                  //             width: 100,
                  //             padding: const EdgeInsets.all(3),
                  //             decoration: BoxDecoration(
                  //               shape: BoxShape.circle,
                  //               border: Border.all(
                  //                 color: AppColors.white.withOpacity(0.6),
                  //                 width: 2,
                  //               ),
                  //             ),
                  //             child: Container(
                  //               decoration: BoxDecoration(
                  //                 color: AppColors.white.withOpacity(0.16),
                  //                 shape: BoxShape.circle,
                  //               ),
                  //               child: Icon(
                  //                 Icons.person_rounded,
                  //                 size: 52,
                  //                 color: AppColors.white,
                  //               ),
                  //             ),
                  //           ),
                  //
                  //           Positioned(
                  //             right: 0,
                  //             bottom: 2,
                  //             child: GestureDetector(
                  //               onTap: _editProfile,
                  //               child: Container(
                  //                 height: 32,
                  //                 width: 32,
                  //                 decoration: BoxDecoration(
                  //                   color: AppColors.white,
                  //                   shape: BoxShape.circle,
                  //                   border: Border.all(
                  //                     color: AppColors.primary,
                  //                     width: 2,
                  //                   ),
                  //                   boxShadow: [
                  //                     BoxShadow(
                  //                       color: AppColors.black26,
                  //                       blurRadius: 6,
                  //                       offset: const Offset(0, 2),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 child: Icon(
                  //                   Icons.edit_rounded,
                  //                   size: 15,
                  //                   color: AppColors.primary,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //
                  //       const SizedBox(height: 16),
                  //
                  //       Text(
                  //         _isGuest ? 'Guest' : (_name.isEmpty ? 'User' : _name),
                  //         style: getExtraBoldStyle(
                  //           fontSize: MyFonts.size20,
                  //           color: AppColors.white,
                  //         ),
                  //       ),
                  //
                  //       const SizedBox(height: 4),
                  //
                  //       Text(
                  //         _isGuest ? 'Login to view your profile' : _email,
                  //         style: getRegularStyle(
                  //           fontSize: MyFonts.size13,
                  //           color: AppColors.white.withOpacity(0.85),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 28),

                  // LOYALTY & WALLET CARDS — flag ke sath wrapped
                  if (AppConstants.enableLoyaltySystem) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Consumer<LoyaltyController>(
                            builder: (context, loyalty, _) {
                              return FeatureStatCard(
                                icon: Icons.emoji_events_rounded,
                                title: 'Loyalty Points',
                                value: '${loyalty.loyaltyPoints.toStringAsFixed(0)} pts',
                                ctaText: 'View & Redeem',
                                isLoading: loyalty.isLoading,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransitions.slideFromRight(const LoyaltyHistoryView()),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Consumer<WalletController>(
                            builder: (context, wallet, _) {
                              return FeatureStatCard(
                                icon: Icons.account_balance_wallet_rounded,
                                title: 'Wallet',
                                value: 'Rs ${wallet.walletAmount.toStringAsFixed(0)}',
                                ctaText: 'View Transactions',
                                isLoading: wallet.isLoading,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransitions.slideFromRight(const WalletHistoryView()),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],

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
                        PageTransitions.slideFromRight(const ChangePasswordView()),
                      );
                    },
                  ),
                  ProfileOptionTile(
                    title: 'Manage Address',
                    icon: Icons.location_on,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideFromRight(const ManageAddressView()),
                      );
                    },
                  ),
                  ProfileOptionTile(
                    title: 'About Us',
                    icon: Icons.info_outline_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransitions.slideFromRight(const AboutUsView()),
                      );
                    },
                  ),
                  if (!_isGuest)
                    ProfileOptionTile(
                      title: 'Manage Order Type',
                      icon: Icons.swap_horiz_rounded,
                      onTap: () {
                        showOrderTypeBottomSheet(context);
                      },
                    ),

                  const SizedBox(height: 24),

                  Text(
                    'Preferences',
                    style: getExtraBoldStyle(
                      fontSize: MyFonts.size17,
                      color: AppColors.text,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Builder(
                    builder: (context) {
                      final isDark = ThemeService.instance.isDarkMode;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dark Mode',
                                style: getSemiBoldStyle(
                                  fontSize: MyFonts.size14,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            Switch(
                              value: isDark,
                              activeColor: AppColors.primary,
                              onChanged: (val) async {
                                await ThemeService.instance.toggleTheme();
                                if (!context.mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  PageTransitions.slideFromRight(
                                    const SplashView(),
                                  ),
                                      (route) => false,
                                );
                              },
                            ),
                          ],
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
                    onTap: _confirmLogout,
                  ),
                  Consumer<HomeController>(
                    builder: (context, home, _) {
                      final data = home.menuModel?.data;
                      if (data == null) return const SizedBox();

                      final isDark = ThemeService.instance.isDarkMode;

                      final socials = <Map<String, dynamic>>[
                        if ((data.facebookProfileUrl ?? '').isNotEmpty)
                          {
                            'type': 'facebook',
                            'icon': Icons.facebook_rounded,
                            'color': const Color(0xFF1877F2),
                          },
                        if ((data.instagramProfileUrl ?? '').isNotEmpty)
                          {
                            'type': 'instagram',
                            'icon': Icons.camera_alt_rounded,
                            'color': const Color(0xFFE1306C),
                          },
                        if ((data.tiktokProfileUrl ?? '').isNotEmpty)
                          {
                            'type': 'tiktok',
                            'icon': Icons.music_note_rounded,
                            'color': isDark ? const Color(0xFFE0E0E0) : const Color(0xFF010101),
                          },
                        if ((data.youtubeProfileUrl ?? '').isNotEmpty)
                          {
                            'type': 'youtube',
                            'icon': Icons.play_arrow_rounded,
                            'color': const Color(0xFFFF0000),
                          },
                        if ((data.xProfileUrl ?? '').isNotEmpty)
                          {
                            'type': 'twitter',
                            'icon': Icons.alternate_email_rounded,
                            'color': isDark ? const Color(0xFFE0E0E0) : const Color(0xFF000000),
                          },
                        if ((data.linkedinProfileUrl ?? '').isNotEmpty)
                          {
                            'type': 'linkedin',
                            'icon': Icons.business_center_rounded,
                            'color': const Color(0xFF0A66C2),
                          },
                      ];

                      if (socials.isEmpty) return const SizedBox();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Follow Us',
                            style: getExtraBoldStyle(
                              fontSize: MyFonts.size17,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Stay connected on social media',
                            style: getRegularStyle(
                              fontSize: MyFonts.size12,
                              color: AppColors.greyText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: socials.map((s) {
                                final Color color = s['color'];
                                return InkWell(
                                  onTap: () => _launchSocialUrl(s['type']),
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    width: 46,
                                    height: 46,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(isDark ? 0.18 : 0.10),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: color.withOpacity(isDark ? 0.30 : 0.18),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(s['icon'], color: color, size: 21),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}