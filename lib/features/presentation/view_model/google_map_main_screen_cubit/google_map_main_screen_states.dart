abstract class GoogleMapMainScreenStates {}

class GoogleMapMainScreenInitialState extends GoogleMapMainScreenStates {}

class GoogleMapMainScreenChangeUserPositionState
    extends GoogleMapMainScreenStates {}

class GoogleMapMainScreenChangeCameraPositionState
    extends GoogleMapMainScreenStates {}

class GoogleMapMainScreenErrorState extends GoogleMapMainScreenStates {
  final String error;

  GoogleMapMainScreenErrorState({required this.error});
}

class AddNewPolygonState extends GoogleMapMainScreenStates {}
