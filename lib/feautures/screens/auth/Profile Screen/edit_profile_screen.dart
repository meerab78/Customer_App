import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import '../../../../core/services/share_prefernces.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String? dateOfBirth;
  final String? gender;

  const EditProfileScreen({
    super.key,
    required this.name,
    this.dateOfBirth,
    this.gender,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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

  // Future<void> _selectDate() async {
  //   final date = await showDatePickerDialog(
  //     context: context,
  //     minDate: DateTime(1950),
  //     maxDate: DateTime.now(),
  //     currentDate: DateTime(2000),
  //   );
  //   if (date == null) return;
  //   setState(() {
  //     _dateOfBirth =
  //     '${date.day}/${date.month}/${date.year}';
  //   });
  // }
  Future<void> _selectDate() async {
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Date of Birth',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedDate == null) return;

                      Navigator.pop(context);
                    },
                    child: const Text('Select Date'),
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Basic Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.greyText,
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _genderOption('Male'),
              _genderOption('Female'),
              _genderOption('Other'),
            ],
          ),
        );
      },
    );
  }

  Widget _genderOption(String gender) {
    return ListTile(
      leading:  Icon(
        Icons.person_outline_rounded,
        color: AppColors.primary,
      ),
      title: Text(gender),
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });

        Navigator.pop(context);
      },
    );
  }
}