import 'package:flutter/material.dart';

class FontStyles {
  // Arabic Text Styles using Amiri font
  static const TextStyle arabicRegular = TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w400,
    height: 1.8, // Better line height for Arabic text
  );

  static const TextStyle arabicBold = TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    height: 1.8,
  );

  // Specific Arabic text styles for different contexts - MUCH LARGER SIZES
  static const TextStyle ayahText = TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w400,
    fontSize: 32, // Increased from 28 to 32
    height: 2.0,
  );

  static const TextStyle doaText = TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w400,
    fontSize: 28, // Increased from 24 to 28
    height: 1.8,
  );

  static const TextStyle dzikrText = TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w400,
    fontSize: 26, // Increased from 22 to 26
    height: 1.8,
  );

  static const TextStyle arabicTitle = TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w700,
    fontSize: 30, // Increased from 26 to 30
    height: 1.8,
  );

  static const TextStyle arabicSubtitle = TextStyle(
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w400,
    fontSize: 24, // Increased from 20 to 24
    height: 1.8,
  );

  // Indonesian text styles using AbhayaLibre (default theme)
  static const TextStyle indonesianRegular = TextStyle(
    fontFamily: 'AbhayaLibre',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle indonesianMedium = TextStyle(
    fontFamily: 'AbhayaLibre',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle indonesianSemiBold = TextStyle(
    fontFamily: 'AbhayaLibre',
    fontWeight: FontWeight.w600,
  );

  static const TextStyle indonesianBold = TextStyle(
    fontFamily: 'AbhayaLibre',
    fontWeight: FontWeight.w700,
  );

  // Helper method to get Arabic text style with custom size
  static TextStyle arabicWithSize(double fontSize, {
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.8,
    );
  }

  // Helper method to get Indonesian text style with custom size
  static TextStyle indonesianWithSize(double fontSize, {
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'AbhayaLibre',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.4,
    );
  }
}

// Widget helper untuk teks Arab dengan styling otomatis
class ArabicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ArabicText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FontStyles.arabicRegular.merge(style),
      textAlign: textAlign ?? TextAlign.right,
      textDirection: TextDirection.rtl,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Widget helper untuk teks Indonesia dengan styling otomatis
class IndonesianText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const IndonesianText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FontStyles.indonesianRegular.merge(style),
      textAlign: textAlign ?? TextAlign.left,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}