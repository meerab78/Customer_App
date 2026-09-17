class Validators {
  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your phone number';
    if (v.length != 11 || !v.startsWith('03')) {
      return 'Enter a valid phone number (03xxxxxxxxx)';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}