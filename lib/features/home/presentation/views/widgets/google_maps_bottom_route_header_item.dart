import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleMapsBottomRouteWidgetHeaderItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const GoogleMapsBottomRouteWidgetHeaderItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(value,
            style: GoogleFonts.cairo()
                .copyWith(fontSize: 18, color: Colors.black.withOpacity(.7))),
        const Spacer(),
        Text(title,
            style: GoogleFonts.cairo()
                .copyWith(fontSize: 18, color: Colors.grey.withOpacity(.7))),
        const SizedBox(
          width: 5,
        ),
        FaIcon(
          icon,
          color: Colors.grey.withOpacity(.8),
          size: 18,
        )
      ],
    );
  }
}
