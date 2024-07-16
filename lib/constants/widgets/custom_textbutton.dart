import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? buttonColor;
  final VoidCallback? onPressed;

  final double textSize;
  final double? buttonColorLightness;

  const CustomTextButton({
    super.key,
    required this.text,
    this.textColor,
    this.buttonColor,
    this.onPressed,
    this.textSize = 14,
    this.buttonColorLightness,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(.2)),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.0), // Change this value as needed
          ),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
          buttonColor ?? const Color(0xff5FCCA5),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          style: GoogleFonts.cairo().copyWith(
              fontSize: textSize,
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
