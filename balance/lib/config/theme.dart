import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static ThemeData get light {
    return ThemeData(
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }
}
