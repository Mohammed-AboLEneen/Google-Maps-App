import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_app/constants/widgets/custom_textbutton.dart';

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
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          ),
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width * .8,
            child: CustomTextButton(
              text: 'ابدأ الان',
              onPressed: () {},
              textSize: 18,
              buttonColor: Colors.blue,
            ),
          )
        ],
      ),
    );
  }
}
