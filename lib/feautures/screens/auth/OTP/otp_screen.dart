import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class OtpScreen extends StatefulWidget {
  final String customerId;

  const OtpScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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

    final success = await provider.verifySignupOtp(
      customerId: widget.customerId,
      otp: _otpController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Account verified successfully'
              : provider.errorMessage ?? 'Invalid OTP',
        ),
      ),
    );
  }

  Future<void> _resendOtp() async {
    final provider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await provider.resendSignupOtp(
      customerId: widget.customerId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'OTP sent again'
              : provider.errorMessage ?? 'Failed to resend OTP',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 120,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 70,
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

                const SizedBox(height: 8),

                const Text(
                  'Enter the OTP sent to your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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

                const SizedBox(height: 10),

                TextButton(
                  onPressed: _resendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}