import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/selected_place_model.dart';
import 'google_maps_bottom_route_header_item.dart';

class GoogleMapsBottomRouteWidget extends StatelessWidget {
  final SelectedPlaceModel selectedPlaceModel;

  const GoogleMapsBottomRouteWidget(
      {super.key, required this.selectedPlaceModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 250,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          Row(
            children: [
              Text(selectedPlaceModel.placeName,
                  style: GoogleFonts.cairo().copyWith(
                      fontSize: 18, color: Colors.black.withOpacity(.7))),
              const Spacer(),
              Text('الوجهة',
                  style: GoogleFonts.cairo().copyWith(
                      fontSize: 18, color: Colors.grey.withOpacity(.8))),
              const SizedBox(
                width: 5,
              ),
              FaIcon(
                FontAwesomeIcons.marker,
                color: Colors.grey.withOpacity(.8),
                size: 18,
              )
            ],
          ),
          GoogleMapsBottomRouteWidgetHeaderItem(
            title: 'الوجهة',
            value: selectedPlaceModel.placeName,
            icon: FontAwesomeIcons.marker,
          ),
          const SizedBox(
            height: 20,
          ),
          GoogleMapsBottomRouteWidgetHeaderItem(
            title: 'الزمن المستغرق',
            value: selectedPlaceModel.time,
            icon: FontAwesomeIcons.clock,
          ),
          const SizedBox(
            height: 20,
          ),
          GoogleMapsBottomRouteWidgetHeaderItem(
            title: 'المسافة',
            value: selectedPlaceModel.distance,
            icon: FontAwesomeIcons.route,
          )
        ],
      ),
    );
  }
}
