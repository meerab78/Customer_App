import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../../core/shared/widgets/custom_button.dart';
import '../../../core/shared/widgets/custom_text_field.dart';

class OtpView extends StatefulWidget {
  final String customerId;

  const OtpView({
    super.key,
    required this.customerId,
  });

  @override
  State<OtpView> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpView> {
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
    final provider = Provider.of<AuthController>(
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
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 70,
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

                const SizedBox(height: 8),

                 Text(
                  'Enter the OTP sent to your email',
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

                const SizedBox(height: 10),

                TextButton(
                  onPressed: _resendOtp,
                  child:  Text(
                    'Resend OTP',
                    style: getBoldStyle(
                      color: AppColors.primary,
                      fontSize: null,
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





