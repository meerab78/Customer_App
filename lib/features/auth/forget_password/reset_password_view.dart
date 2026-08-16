import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;

  const ResetPasswordView({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordView> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      return;
    }

    if (_passwordController.text !=
        _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    final provider = Provider.of<AuthController>(
      context,
      listen: false,
    );

    final success = await provider.changePassword(
      restaurantId: '1248',
      email: widget.email,
      newPassword: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
        ),
      );

      Navigator.popUntil(
        context,
            (route) => route.isFirst,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to change password',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 35),

               Icon(
                Icons.lock_reset_rounded,
                size: 75,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              Text(
                'Create New Password',
                style: getBoldStyle(
                  fontSize: MyFonts.size25,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter your new password below',
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  color: AppColors.greyText,
                  fontSize: null,
                ),
              ),

              const SizedBox(height: 30),

              CustomTextField(
                controller: _passwordController,
                hintText: 'New password',
                prefixIcon: Icons.lock_outline,
                obscureText: _hidePassword,
                onVisibilityTap: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              ),

              const SizedBox(height: 12),

              CustomTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm new password',
                prefixIcon: Icons.lock_outline,
                obscureText: _hideConfirmPassword,
                textInputAction: TextInputAction.done,
                onVisibilityTap: () {
                  setState(() {
                    _hideConfirmPassword =
                    !_hideConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 20),

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
    );
  }
}





