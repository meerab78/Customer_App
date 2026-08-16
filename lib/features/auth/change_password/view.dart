import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_text_field.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordView> {

  final _formKey = GlobalKey<FormState>();

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<AuthController>(
      context,
      listen: false,
    );

    // User ki saved information SharedPreferences se milegi
    final email = await provider.getSavedUserEmail();
    final restaurantId = await provider.getSavedRestaurantId();

    if (email == null || restaurantId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User information not found'),
        ),
      );

      return;
    }

    final success =
    await provider.changePassword(
      restaurantId: restaurantId.toString(),
      email: email,
      newPassword: _newPasswordController.text.trim(),
      confirmPassword:
      _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to change password',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // appBar: AppBar(
      //   title: const Text(
      //     'Change Password',
      //     style: TextStyle(
      //       fontWeight: FontWeight.w700,
      //     ),
      //   ),
      // ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            20,
            18,
            30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Change your password',
                  style: getExtraBoldStyle(
                    fontSize: MyFonts.size22,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Enter your new password below.',
                  style: getRegularStyle(
                    fontSize: MyFonts.size13,
                    color: AppColors.greyText,
                  ),
                ),

                const SizedBox(height: 25),

                CustomTextField(
                  controller: _newPasswordController,
                  hintText: 'New password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureNewPassword,
                  textInputAction: TextInputAction.next,
                  onVisibilityTap: () {
                    setState(() {
                      _obscureNewPassword =
                      !_obscureNewPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onVisibilityTap: () {
                    setState(() {
                      _obscureConfirmPassword =
                      !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }

                    if (value !=
                        _newPasswordController.text) {
                      return 'Passwords do not match';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 28),

                Consumer<AuthController>(
                  builder: (context, provider, child) {
                    return CustomButton(
                      text: 'Change Password',
                      isLoading: provider.isLoading,
                      onPressed: _changePassword,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




