import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_app/cores/errors/server_failure.dart';
import 'package:google_maps_app/cores/utlis/dio_helper.dart';
import 'package:google_maps_app/features/presentation/view_model/places_cubit/places_states.dart';

class PlacesCubit extends Cubit<PlacesStates> {
  PlacesCubit() : super(PlacesInitialState());

  static PlacesCubit get(context) => BlocProvider.of(context);

  List<dynamic> places = [];

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
      emit(SelectPlaceSuccessState(locations.first));
    } catch (e) {
      log(e.toString());
      emit(SelectPlaceErrorState(e.toString()));
    }
  }
}
