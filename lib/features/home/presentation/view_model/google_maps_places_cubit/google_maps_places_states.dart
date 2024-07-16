import '../../../data/selected_place_model.dart';

abstract class GoogleMapsPlacesStates {}

class GoogleMapsPlacesInitialState extends GoogleMapsPlacesStates {}

class GetPlacesLoadingState extends GoogleMapsPlacesStates {}

class GetPlacesSuccessState extends GoogleMapsPlacesStates {}

class GetPlacesErrorState extends GoogleMapsPlacesStates {
  final String error;

  GetPlacesErrorState(this.error);
}

class SelectPlaceLoadingState extends GoogleMapsPlacesStates {}

class SelectPlaceSuccessState extends GoogleMapsPlacesStates {
  SelectedPlaceModel selectedPlaceModel;

  SelectPlaceSuccessState(this.selectedPlaceModel);
}

class SelectPlaceErrorState extends GoogleMapsPlacesStates {
  String error;

  SelectPlaceErrorState(this.error);
}
