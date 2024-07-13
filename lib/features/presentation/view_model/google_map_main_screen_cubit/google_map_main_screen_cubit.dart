import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../constants.dart';
import 'google_map_main_screen_states.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:geolocator/geolocator.dart';

class GoogleMapMainScreenCubit extends Cubit<GoogleMapMainScreenStates> {
  GoogleMapMainScreenCubit() : super(GoogleMapMainScreenInitialState());

  static GoogleMapMainScreenCubit get(context) => BlocProvider.of(context);

  LatLng? currentLocation;
  LatLng? destinationLocation;
  LocationSettings? locationSettings;

  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = {};
  int count = 0;

  late Completer<GoogleMapController> googleMapController;

  Future<void> getUserCurrentLocation(
      Completer<GoogleMapController> controller) async {
    googleMapController = controller;
    bool status = await checkPermissions();

    try {
      if (status) {
        await initLocationSettings();
        await getPositionStream();
        // List<LatLng> points = await getPolygonPoints();
        // generatePolygon(points);
      }
    } catch (e) {
      emit(GoogleMapMainScreenErrorState(error: e.toString()));
    }
  }

  Future<bool> checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (serviceEnabled) {
      return true;
    }
    return false;
  }

  Future<void> getPositionStream() async {
    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        currentLocation = LatLng(position.latitude, position.longitude);

        addMarker(currentLocation!, true);
        emit(GoogleMapMainScreenChangeUserPositionState());
      }
    });
  }

  Future<void> newCameraPosition(LatLng? position) async {
    CameraPosition cameraPosition = CameraPosition(
      target: position!,
      zoom: 14,
    );
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    emit(GoogleMapMainScreenChangeCameraPositionState());
  }

  Future<void> initLocationSettings() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                "Example app will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
  }

  void addMarker(LatLng latLng, bool isCurrentLocation) {
    if (isCurrentLocation == false && markers.length > 1) {
      List<Marker> list = markers.toList();
      list.removeAt(1);
      markers = list.toSet();
    }
    markers.add(
      Marker(
        markerId: MarkerId("${markers.length + 1}"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(isCurrentLocation
            ? BitmapDescriptor.hueAzure
            : BitmapDescriptor.hueRed),
        onTap: () {
          if (markers.length > 1) {}
        },
      ),
    );

    polylines.clear();

    emit(GoogleMapMainScreenChangeCameraPositionState());

    newCameraPosition(latLng);
  }

  Future<void> generatePolygon() async {
    polylines.clear();

    List<LatLng> points = await getPolygonPoints();
    if (points.isEmpty) {
      return;
    }

    final polygonId = PolylineId('$count');
    final polygon = Polyline(
        points: points,
        polylineId: polygonId,
        color: Colors.lightBlueAccent,
        width: 6);
    polylines[polygonId] = polygon;
    count++;

    emit(AddNewPolygonState());
  }

  Future<List<LatLng>> getPolygonPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
          origin: PointLatLng(markers.first.position.latitude,
              markers.first.position.longitude),
          destination: PointLatLng(
              markers.last.position.latitude, markers.last.position.longitude),
          mode: TravelMode.driving,
          optimizeWaypoints: true),
      googleApiKey: googleMapsApiKey,
    );

    if (result.status == 'OK' && result.points.isNotEmpty) {
      return result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    } else {
      log('Error: ${result.errorMessage}');
      return [];
    }
  }
}
