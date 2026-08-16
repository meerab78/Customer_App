import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_text_field.dart';
import 'forgot_otp_view.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgetPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      return;
    }

    final provider = Provider.of<AuthController>(
      context,
      listen: false,
    );

    final success = await provider.sendForgotPasswordOtp(
      restaurantId: 1248,
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotOtpView(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to send OTP',
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
        title: const Text('Forgot Password'),
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
                'Forgot Password?',
                style: getBoldStyle(
                  fontSize: MyFonts.size26,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Enter your email and we will send you an OTP',
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  color: AppColors.greyText,
                  fontSize: null,
                ),
              ),

              const SizedBox(height: 30),

              CustomTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 20),

              Consumer<AuthController>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Send OTP',
                    isLoading: provider.isLoading,
                    onPressed: _sendOtp,
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





