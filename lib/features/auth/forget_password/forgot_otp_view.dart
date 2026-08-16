import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_text_field.dart';
import 'reset_password_view.dart';

class ForgotOtpView extends StatefulWidget {
  final String email;

  const ForgotOtpView({
    super.key,
    required this.email,
  });

  @override
  State<ForgotOtpView> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpView> {
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

    final provider = Provider.of<AuthController>(
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
          builder: (_) => ResetPasswordView(
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

              Icon(
                Icons.mark_email_read_outlined,
                size: 75,
                color: AppColors.primary,
              ),

              const SizedBox(height: 20),

              Text(
                'Enter OTP',
                style: getBoldStyle(
                  fontSize: MyFonts.size26,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter the OTP sent to ${widget.email}',
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  color: AppColors.greyText,
                  fontSize: null,
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

              Consumer<AuthController>(
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





