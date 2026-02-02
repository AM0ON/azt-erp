class InputSanitizer {
  static String clean(String input) {
    if (input.trim().isEmpty) return "";
    
    String sanitized = input.trim();
    
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    
    sanitized = sanitized.replaceAll(RegExp(r"[';]"), '');
    
    sanitized = sanitized.replaceAll(RegExp(r'--'), '');
    
    sanitized = sanitized.replaceAll(RegExp(r'/\*|\*/'), '');
    
    return sanitized;
  }
}