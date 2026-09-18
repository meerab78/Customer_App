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

  Widget _section(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: getBoldStyle(
                  fontSize: MyFonts.size17,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content.isEmpty ? 'No content available.' : content,
            style: getRegularStyle(
              fontSize: MyFonts.size14,
              color: AppColors.text,
            ).copyWith(
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = context.watch<HomeController>().menuModel?.data?.logoUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          color: AppColors.text,
        ),
        title: Text(
          'About Us',
          style: getBoldStyle(
            fontSize: MyFonts.size18,
            color: AppColors.text,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section('About Us', _aboutUs),
                    _section(
                      'Terms & Conditions',
                      _termsAndConditions,
                    ),
                  ],
                ),
              ),
            ),
            if (logoUrl != null && logoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                  top: 4,
                ),
                child: GestureDetector(
                  onTap: () => _openLogoLink(logoUrl),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.network(
                      logoUrl,
                      height: 50,
                      errorBuilder: (_, __, ___) =>
                      const SizedBox(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}