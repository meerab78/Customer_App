import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
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

    final provider = Provider.of<AuthProvider>(
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
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter your new password below',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.greyText,
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

              Consumer<AuthProvider>(
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