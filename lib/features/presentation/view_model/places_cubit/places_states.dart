abstract class PlacesStates {}

class PlacesInitialState extends PlacesStates {}

class GetPlacesLoadingState extends PlacesStates {}

class GetPlacesSuccessState extends PlacesStates {}

class GetPlacesErrorState extends PlacesStates {
  final String error;

  GetPlacesErrorState(this.error);
}
