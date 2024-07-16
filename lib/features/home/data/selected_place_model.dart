import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedPlaceModel {
  final String time;
  final String placeName;
  final String distance;
  final LatLng placeLocation;
  final Map<PolylineId, Polyline> routesPolyline;

  SelectedPlaceModel(
      {required this.time,
      required this.placeName,
      required this.distance,
      required this.placeLocation,
      required this.routesPolyline});
}
