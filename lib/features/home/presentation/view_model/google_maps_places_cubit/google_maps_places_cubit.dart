import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_app/cores/errors/server_failure.dart';
import 'package:google_maps_app/cores/utlis/dio_helper.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../constants/methods/get_route_points.dart';
import '../../../data/selected_place_model.dart';
import 'google_maps_places_states.dart';

class GoogleMapsPlacesCubit extends Cubit<GoogleMapsPlacesStates> {
  GoogleMapsPlacesCubit() : super(GoogleMapsPlacesInitialState());

  static GoogleMapsPlacesCubit get(context) => BlocProvider.of(context);

  List<dynamic> places = [];

  late LatLng currentLocation;

  Map<PolylineId, Polyline> routesPolyline = {};
  late List<String> drivingTime = [];

  void initCurrentLocation(LatLng latLng) {
    currentLocation = latLng;
  }

  Future<void> getPlaces(String searchKey) async {
    emit(GetPlacesLoadingState());

    places = [];

    try {
      Response response = await DioHelper.get(query: {
        'input': searchKey,
      });

      places =
          response.data['predictions'].map((e) => e['description']).toList();

      emit(GetPlacesSuccessState());
    } catch (e) {
      if (e is DioException) {
        emit(GetPlacesErrorState(ServerFailure.dioError(e).message));
      } else {
        log(e.toString());
        emit(GetPlacesErrorState(e.toString()));
      }
    }
  }

  Future<void> selectPlace(String place) async {
    emit(SelectPlaceLoadingState());
    try {
      List<Location> locations = await locationFromAddress(place);

      double distance = Geolocator.distanceBetween(
          currentLocation.latitude,
          currentLocation.longitude,
          locations.first.latitude,
          locations.first.longitude);
      ;

      await generatePolyLines(
        destLocation: LatLng(locations[0].latitude, locations[0].longitude),
      );

      int calculatedDistance = distance.toInt();
      SelectedPlaceModel selectedPlaceModel = SelectedPlaceModel(
          time: drivingTime.first,
          placeName: place,
          distance: '${calculatedDistance.toString()} M',
          routesPolyline: routesPolyline,
          placeLocation: LatLng(locations[0].latitude, locations[0].longitude));

      emit(SelectPlaceSuccessState(selectedPlaceModel));
    } catch (e) {
      print(e.toString());
      emit(SelectPlaceErrorState(e.toString()));
    }
  }

  Future<void> generatePolyLines({required LatLng destLocation}) async {
    List<LatLng> points = await getPolygonPoints(
        sourceLocation: currentLocation,
        destLocation: destLocation,
        drivingTime: drivingTime);

    if (points.isEmpty) return;

    const polygonId = PolylineId('1');
    final polygon = Polyline(
        points: points,
        polylineId: polygonId,
        color: Colors.lightBlueAccent,
        width: 6);
    routesPolyline[polygonId] = polygon;
  }
}
