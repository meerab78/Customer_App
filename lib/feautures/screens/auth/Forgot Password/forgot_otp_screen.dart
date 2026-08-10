import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import 'reset_password_screen.dart';

class ForgotOtpScreen extends StatefulWidget {
  final String email;

  const ForgotOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<ForgotOtpScreen> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      return;
    }

    final provider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await provider.verifyForgotPasswordOtp(
      restaurantId: '1248',
      email: widget.email,
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Invalid OTP',
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
        title: const Text('Verify OTP'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 35),

              const Icon(
                Icons.mark_email_read_outlined,
                size: 75,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter the OTP sent to ${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.greyText,
                ),
              ),

              const SizedBox(height: 30),

              CustomTextField(
                controller: _otpController,
                hintText: 'Enter OTP',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 20),

              Consumer<AuthProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Verify OTP',
                    isLoading: provider.isLoading,
                    onPressed: _verifyOtp,
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