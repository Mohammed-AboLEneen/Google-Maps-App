import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants.dart';
import 'location_search_screen.dart';

class MainScreen extends StatefulWidget {
  final double? lat;
  final double? long;

  const MainScreen({super.key, this.lat, this.long});

  @override
  State<MainScreen> createState() => _HomePageState();
}

class _HomePageState extends State<MainScreen> {
  LatLng? currentLocation;
  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  LocationSettings? locationSettings;

  LatLng? destination = const LatLng(30.5392, 31.1036);

  Map<PolygonId, Polygon> polygons = {};

  @override
  void initState() {
    super.initState();

    getUserCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 13,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      googleMapController.complete(controller);
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: currentLocation!,
                      ),
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: destination!,
                      ),
                    },
                    scrollGesturesEnabled: true,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    polygons: Set<Polygon>.of(polygons.values),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                            labelText: 'Search',
                            labelStyle: TextStyle(color: Colors.black),
                            fillColor: Colors.white,
                            // Set your desired color
                            filled: true,
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide.none)),
                        onTap: () {
                          Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, animation, ___) =>
                                    SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, -1),
                                    // Start from completely off-screen (top)
                                    end: const Offset(
                                        0, 0), // Slide down to full visibility
                                  ).animate(animation),
                                  child: const SearchLocationScreen(),
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                              ));
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future<void> getUserCurrentLocation() async {
    bool status = await checkPermissions();

    if (status) {
      await initLocationSettings();
      await getPositionStream();
      // List<LatLng> points = await getPolygonPoints();
      // generatePolygon(points);
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
      print('state: ${position?.latitude}, ${position?.longitude}');
      setState(() {
        if (position != null) {
          currentLocation = LatLng(position.latitude, position.longitude);

          print(
              'currentLocation: ${currentLocation?.latitude}, ${currentLocation?.longitude}');
          newCameraPosition(currentLocation);
        }
      });
    });
  }

  Future<void> newCameraPosition(LatLng? position) async {
    CameraPosition cameraPosition = CameraPosition(
      target: position!,
      zoom: 14,
    );
    final GoogleMapController controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<List<LatLng>> getPolygonPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
            origin: PointLatLng(
                currentLocation!.latitude, currentLocation!.longitude),
            destination:
                PointLatLng(destination!.latitude, destination!.longitude),
            mode: TravelMode.driving),
        googleApiKey: googleMapsApiKey);

    if (result.points.isEmpty) {
      return [];
    }

    return result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
  }

  void generatePolygon(List<LatLng> points) {
    final polygonId = PolygonId('1');
    final polygon = Polygon(
      polygonId: polygonId,
      points: points,
      strokeWidth: 10,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.5),
    );
    setState(() {
      polygons[polygonId] = polygon;
    });
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
}
