
import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import '../../core/db/shared_pref.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/fonts_manager.dart';
import '../../core/theme/textfont_styles.dart';
import '../../core/shared/widgets/custom_button.dart';
import '../../core/shared/widgets/custom_text_field.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class EditProfileView extends StatefulWidget {
  final String name;
  final String? dateOfBirth;
  final String? gender;

  const EditProfileView({
    super.key,
    required this.name,
    this.dateOfBirth,
    this.gender,
  });

  @override
  State<EditProfileView> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileView> {
  late TextEditingController _nameController;

  String? _selectedGender;
  String? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.name,
    );
    _selectedGender = widget.gender;
    _dateOfBirth = widget.dateOfBirth;
  }
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  Future<void> _selectDate() async {
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Text(
                  'Select Date of Birth',
                  style: getBoldStyle(
                    fontSize: MyFonts.size20,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 20),

                EasyDateTimeLinePicker(
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  focusedDate: DateTime(2000),
                  onDateChange: (date) {
                    selectedDate = date;
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedDate == null) return;

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Select Date',
                      style: getBoldStyle(
                        color: AppColors.white,
                        fontSize: MyFonts.size15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDate == null) return;

    setState(() {
      _dateOfBirth =
      '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );
      return;
    }

    final prefs = SharedPrefService();

    await prefs.saveProfileDetails(
      name: _nameController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _selectedGender,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
      ),
    );

    Navigator.pop(context, true);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit Profile',
          style: getBoldStyle(
            color: AppColors.text,
            fontSize: MyFonts.size18,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avatar
            Center(
              child: Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.16),
                      AppColors.primary.withOpacity(0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    height: 62,
                    width: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.30),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 30,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Basic Details',
              style: getExtraBoldStyle(
                fontSize: MyFonts.size18,
                color: AppColors.text,
              ),
            ),

            const SizedBox(height: 14),

            _profileField(
              child: CustomTextField(
                controller: _nameController,
                hintText: 'Your name',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
              ),
            ),

            const SizedBox(height: 12),

            _profileTile(
              icon: Icons.calendar_month_outlined,
              title: 'Date of Birth',
              value: _dateOfBirth ?? 'Select your date of birth',
              onTap: _selectDate,
            ),

            const SizedBox(height: 12),

            _profileTile(
              icon: Icons.wc_outlined,
              title: 'Gender',
              value: _selectedGender ?? 'Select your gender',
              onTap: _showGenderPicker,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Save Changes',
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileField({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow04,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.grey200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.softShadow04,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 23,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: getRegularStyle(
                      fontSize: MyFonts.size12,
                      color: AppColors.greyText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: getSemiBoldStyle(
                      fontSize: MyFonts.size15,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Text(
                  'Select Gender',
                  style: getBoldStyle(
                    fontSize: MyFonts.size18,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 10),

                _genderOption('Male', Icons.male_rounded),
                _genderOption('Female', Icons.female_rounded),
                _genderOption('Other', Icons.person_outline_rounded),

                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _genderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });

          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.grey100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.transparent,
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  gender,
                  style: getSemiBoldStyle(
                    fontSize: MyFonts.size14,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}