class AppValidators {
  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'[-\s]'), '');
    final regex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,11}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Format tidak valid (contoh: 08123456789)';
    }
    return null;
  }

  static String? minLength(String? value, int min,
      {String fieldName = 'Field'}) {
    if (value == null || value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  static String? passwordMatch(String? password, String? confirm) {
    if (password != confirm) return 'Password tidak cocok';
    return null;
  }

  static String? customerNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor pelanggan wajib diisi';
    }
    if (value.trim().length < 5) {
      return 'Nomor pelanggan minimal 5 digit';
    }
    return null;
  }
}