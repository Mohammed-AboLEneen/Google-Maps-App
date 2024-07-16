import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/selected_place_model.dart';
import '../view_model/google_map_main_screen_cubit/google_map_home_view_cubit.dart';
import '../view_model/google_map_main_screen_cubit/google_map_home_view_states.dart';
import 'search_location_view.dart';

class HomeView extends StatefulWidget {
  final double? lat;
  final double? long;

  const HomeView({super.key, this.lat, this.long});

  @override
  State<HomeView> createState() => _HomePageState();
}

class _HomePageState extends State<HomeView> {
  final Completer<GoogleMapController> googleMapController =
      Completer<GoogleMapController>();

  LatLng? destinationLocation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => GoogleMapMainScreenCubit()
          ..getUserCurrentLocation(context, googleMapController),
        child: BlocBuilder<GoogleMapMainScreenCubit, GoogleMapMainScreenStates>(
          builder: (context, state) {
            GoogleMapMainScreenCubit googleMapMainScreenCubit =
                GoogleMapMainScreenCubit.get(context);

            if (state is GoogleMapMainScreenErrorState) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'There was an error: ${state.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          googleMapMainScreenCubit.getUserCurrentLocation(
                              context, googleMapController);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }

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
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        googleMapController.complete(controller);
                      },
                      markers: googleMapMainScreenCubit.markers,
                      scrollGesturesEnabled: true,
                      gestureRecognizers: <Factory<
                          OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                      polylines: Set<Polyline>.of(
                          googleMapMainScreenCubit.polylines.values),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () async {
                          SelectedPlaceModel? selectedPlace =
                              await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, animation, ___) =>
                                        SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        // Start from completely off-screen (top)
                                        end: const Offset(0,
                                            0), // Slide down to full visibility
                                      ).animate(animation),
                                      child: SearchLocationView(
                                          currentLocation:
                                              googleMapMainScreenCubit
                                                  .currentLocation),
                                    ),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                  ));

                          if (selectedPlace != null) {
                            destinationLocation = selectedPlace.placeLocation;

                            if (!context.mounted) return;
                            googleMapMainScreenCubit
                                .initSelectedPlace(selectedPlace);
                            googleMapMainScreenCubit.addMarker(
                                context, destinationLocation!,
                                isCurrentLocation: false);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              const Icon(Icons.search),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Search',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.8),
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ));
            }
          },
        ));
  }
}
