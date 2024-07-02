import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_app/features/presentation/view_model/google_map_main_screen_cubit/google_map_main_screen_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../view_model/google_map_main_screen_cubit/google_map_main_screen_states.dart';
import 'location_search_screen.dart';

class MainScreen extends StatefulWidget {
  final double? lat;
  final double? long;

  const MainScreen({super.key, this.lat, this.long});

  @override
  State<MainScreen> createState() => _HomePageState();
}

class _HomePageState extends State<MainScreen> {
  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => GoogleMapMainScreenCubit()
          ..getUserCurrentLocation(googleMapController),
        child:
            BlocConsumer<GoogleMapMainScreenCubit, GoogleMapMainScreenStates>(
          builder: (context, state) {
            GoogleMapMainScreenCubit googleMapMainScreenCubit =
                GoogleMapMainScreenCubit.get(context);

            print(googleMapMainScreenCubit.currentLocation);
            if (googleMapMainScreenCubit.currentLocation == null) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return Scaffold(
                  body: SafeArea(
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: googleMapMainScreenCubit.currentLocation!,
                        zoom: 13,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        googleMapController.complete(controller);
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('currentLocation'),
                          position: googleMapMainScreenCubit.currentLocation!,
                        ),
                        const Marker(
                          markerId: MarkerId('destination'),
                          position: LatLng(30.5392, 31.1036),
                        ),
                      },
                      scrollGesturesEnabled: true,
                      gestureRecognizers: <Factory<
                          OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      //  polygons: Set<Polygon>.of(polygons.values),
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
                                      end: const Offset(0,
                                          0), // Slide down to full visibility
                                    ).animate(animation),
                                    child: const SearchLocationScreen(),
                                  ),
                                  transitionDuration:
                                      const Duration(milliseconds: 400),
                                ));
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ));
            }
          },
          listener: (context, state) {},
        ));
  }
}
