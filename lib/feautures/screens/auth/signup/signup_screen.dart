
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../Login/login_screen.dart';
import '../OTP/otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await provider.signup(
      email: _emailController.text.trim(),
      restaurantId: 1248,
      cellNum: _phoneController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final response = provider.signupResponse;

      final customerId = response['Data']['customer_id'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(
            customerId: customerId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Something went wrong',
          ),
        ),
      );
    }
  }
  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                // Header
                Container(
                  height: 245,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -65,
                        right: -45,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 15),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              // child: IconButton(
                              //   onPressed: () => Navigator.pop(context),
                              //   padding: EdgeInsets.zero,
                              //   constraints: const BoxConstraints(),
                              //   icon: const Icon(
                              //     Icons.arrow_back_rounded,
                              //     color: Colors.white,
                              //     size: 27,
                              //   ),
                              // ),
                            ),

                            const SizedBox(height: 30),

                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(21),
                              ),
                              child:  Icon(
                                Icons.restaurant_rounded,
                                color: AppColors.primary,
                                size: 35,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Join us and enjoy your favorite meals',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(17, 17, 17, 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(27),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                         Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Let's get started",
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 3),

                         Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter your details to create your account',
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 11.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) =>
                              _required(value, 'Please enter your name'),
                        ),

                        const SizedBox(height: 9),

                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Enter your email address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 9),

                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Enter your phone number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) => _required(
                            value,
                            'Please enter your phone number',
                          ),
                        ),

                        const SizedBox(height: 9),

                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Create a password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          onVisibilityTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 9),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm your password',
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
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: Consumer<AuthProvider>(
                            builder: (context, provider, child) {
                              return CustomButton(
                                text: 'Create Account',
                                isLoading: provider.isLoading,
                                onPressed: _createAccount,
                              );
                            },
                          )
                        ),

                        const SizedBox(height: 10),

                        RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                  },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),

                         Text(
                          'By creating an account, you agree to our Terms & Conditions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.greyText,
                            fontSize: 9,
                          ),
                        ),
                      ],
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

