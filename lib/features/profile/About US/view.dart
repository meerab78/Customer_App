// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/fonts_manager.dart';
// import '../../../core/theme/textfont_styles.dart';
// import '../../home/controller.dart';
// import 'content_repository.dart';
//
// class AboutUsView extends StatefulWidget {
//   const AboutUsView({super.key});
//
//   @override
//   State<AboutUsView> createState() => _AboutUsViewState();
// }
//
// class _AboutUsViewState extends State<AboutUsView> {
//   final ContentRepository _repo = ContentRepository();
//
//   bool _isLoading = true;
//   String _aboutUs = '';
//   String _termsAndConditions = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadContent();
//   }
//
//   Future<void> _loadContent() async {
//     try {
//       final result = await _repo.getRestaurantContent();
//       if (!mounted) return;
//       setState(() {
//         _aboutUs = result.data?.aboutUs ?? '';
//         _termsAndConditions = result.data?.termsAndConditions ?? '';
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   Future<void> _openLogoLink(String url) async {
//     final uri = Uri.tryParse(url);
//     if (uri == null) return;
//     try {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Could not open link')),
//       );
//     }
//   }
//
//   Widget _section(String title, String content) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 18),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Text(
//                 title,
//                 style: getBoldStyle(
//                   fontSize: MyFonts.size17,
//                   color: AppColors.text,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Text(
//             content.isEmpty ? 'No content available.' : content,
//             style: getRegularStyle(
//               fontSize: MyFonts.size14,
//               color: AppColors.text,
//             ).copyWith(
//               height: 1.65,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final logoUrl = context.watch<HomeController>().menuModel?.data?.logoUrl;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         centerTitle: false,
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             size: 20,
//           ),
//           color: AppColors.text,
//         ),
//         title: Text(
//           'About Us',
//           style: getBoldStyle(
//             fontSize: MyFonts.size18,
//             color: AppColors.text,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(
//         child: CircularProgressIndicator(),
//       )
//           : SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _section('About Us', _aboutUs),
//                     _section(
//                       'Terms & Conditions',
//                       _termsAndConditions,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (logoUrl != null && logoUrl.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(
//                   bottom: 20,
//                   top: 4,
//                 ),
//                 child: GestureDetector(
//                   onTap: () => _openLogoLink(logoUrl),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.04),
//                           blurRadius: 10,
//                           offset: const Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: Image.network(
//                       logoUrl,
//                       height: 50,
//                       errorBuilder: (_, __, ___) =>
//                       const SizedBox(),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';
import '../../home/controller.dart';
import 'content_repository.dart';

class AboutUsView extends StatefulWidget {
  const AboutUsView({super.key});

  @override
  State<AboutUsView> createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  final ContentRepository _repo = ContentRepository();

  bool _isLoading = true;
  String _aboutUs = '';
  String _termsAndConditions = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final result = await _repo.getRestaurantContent();
      if (!mounted) return;
      setState(() {
        _aboutUs = result.data?.aboutUs ?? '';
        _termsAndConditions = result.data?.termsAndConditions ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openLogoLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  Widget _section({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.16),
                      AppColors.primary.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 19, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: getExtraBoldStyle(
                    fontSize: MyFonts.size17,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Container(
              width: 32,
              height: 2.5,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content.isEmpty ? 'No content available.' : content,
            style: getRegularStyle(
              fontSize: MyFonts.size14,
              color: AppColors.greyText,
            ).copyWith(height: 1.75, letterSpacing: 0.1),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<HomeController>().menuModel?.data;
    final logoUrl = data?.logoUrl;
    final restaurantName = data?.name;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // ===== HERO HEADER =====
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative circle accents
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 30,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.16),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 17,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        Container(
                          width: 68,
                          height: 68,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black26,
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 34,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          restaurantName ?? 'About Us',
                          style: getExtraBoldStyle(
                            fontSize: MyFonts.size25,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Learn more about who we are\nand our terms of service',
                          style: getRegularStyle(
                            fontSize: MyFonts.size13,
                            color: AppColors.white.withOpacity(0.85),
                          ).copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== CONTENT =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(
                    title: 'About Us',
                    icon: Icons.info_outline_rounded,
                    content: _aboutUs,
                  ),
                  _section(
                    title: 'Terms & Conditions',
                    icon: Icons.description_outlined,
                    content: _termsAndConditions,
                  ),
                ],
              ),
            ),
          ),

          // ===== LOGO / FOOTER =====
          // if (logoUrl != null && logoUrl.isNotEmpty)
          //   SliverToBoxAdapter(
          //     child: Padding(
          //       padding: const EdgeInsets.fromLTRB(20, 4, 20, 34),
          //       child: Center(
          //         child: InkWell(
          //           onTap: () => _openLogoLink(logoUrl),
          //           borderRadius: BorderRadius.circular(20),
          //           child: Container(
          //             width: double.infinity,
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 24,
          //               vertical: 22,
          //             ),
          //             decoration: BoxDecoration(
          //               color: AppColors.card,
          //               borderRadius: BorderRadius.circular(20),
          //               border: Border.all(color: AppColors.borderLight),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: AppColors.shadow,
          //                   blurRadius: 16,
          //                   offset: const Offset(0, 5),
          //                 ),
          //               ],
          //             ),
          //             child: Image.network(
          //               logoUrl,
          //               height: 46,
          //               errorBuilder: (_, __, ___) => const SizedBox(),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}