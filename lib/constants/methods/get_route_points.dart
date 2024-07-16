import 'dart:developer';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants.dart';

Future<List<LatLng>> getPolygonPoints(
    {required LatLng sourceLocation,
    required LatLng destLocation,
    required List<String> drivingTime}) async {
  PolylinePoints polylinePoints = PolylinePoints();
  PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    request: PolylineRequest(
        origin: PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        destination: PointLatLng(destLocation.latitude, destLocation.longitude),
        mode: TravelMode.driving,
        optimizeWaypoints: true),
    googleApiKey: googleMapsApiKey,
  );

  drivingTime.addAll(result.durationTexts?.toList() ?? []);

  if (result.status == 'OK' && result.points.isNotEmpty) {
    return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
  } else {
    log('Error: ${result.errorMessage}');
    return [];
  }
}
