import 'package:geocoding/geocoding.dart';

abstract class PlacesStates {}

class PlacesInitialState extends PlacesStates {}

class GetPlacesLoadingState extends PlacesStates {}

class GetPlacesSuccessState extends PlacesStates {}

class GetPlacesErrorState extends PlacesStates {
  final String error;

  GetPlacesErrorState(this.error);
}

class SelectPlaceLoadingState extends PlacesStates {}

class SelectPlaceSuccessState extends PlacesStates {
  Location location;

  SelectPlaceSuccessState(this.location);
}

class SelectPlaceErrorState extends PlacesStates {
  String error;

  SelectPlaceErrorState(this.error);
}
