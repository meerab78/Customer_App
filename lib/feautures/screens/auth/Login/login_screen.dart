

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../home/main_navigation_screen.dart';
import '../Forgot Password/forgot_password.dart';
import '../signup/signup_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await provider.login(
      restaurantId: '1248',
      email: _emailController.text.trim(),
      orderResourceId: '3',
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(
            initialIndex: 0,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Login failed',
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          // child: IconButton(
                          //   onPressed: () => Navigator.pop(context),
                          //   icon: const Icon(
                          //     Icons.arrow_back_rounded,
                          //     color: Colors.white,
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
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: AppColors.primary,
                            size: 35,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Login to continue ordering your favorite meals',
                          style: TextStyle(
                            color: Colors.white.withOpacity(.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
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
                            'Login to your account',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter your email and password',
                            style: TextStyle(
                              color: AppColors.greyText,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Enter your email address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your email';
                            }

                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onVisibilityTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }

                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Consumer<AuthProvider>(
                          builder: (context, provider, child) {
                            return CustomButton(
                              text: 'Login',
                              isLoading: provider.isLoading,
                              onPressed: _login,
                            );
                          },
                        ),
                        const SizedBox(height: 14),

                        RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style:  TextStyle(
                              color: AppColors.greyText,
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: 'Create Account',
                                style:  TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
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

