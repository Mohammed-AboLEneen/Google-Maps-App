import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../constants/constants.dart';
import 'widgets/location_list_tile.dart';
import '../view_model/google_maps_places_cubit/google_maps_places_cubit.dart';
import '../view_model/google_maps_places_cubit/google_maps_places_states.dart';

class SearchLocationView extends StatefulWidget {
  final LatLng? currentLocation;

  const SearchLocationView({super.key, this.currentLocation});

  @override
  State<SearchLocationView> createState() => _SearchLocationViewState();
}

class _SearchLocationViewState extends State<SearchLocationView> {
  final TextEditingController searchController = TextEditingController();

  bool canSearch = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GoogleMapsPlacesCubit()..initCurrentLocation(widget.currentLocation!),
      child: BlocConsumer<GoogleMapsPlacesCubit, GoogleMapsPlacesStates>(
        builder: (context, state) {
          GoogleMapsPlacesCubit placesCubit =
              GoogleMapsPlacesCubit.get(context);

          return Scaffold(
            appBar: AppBar(
              leading: const Padding(
                padding: EdgeInsets.only(left: defaultPadding),
                child: CircleAvatar(
                  backgroundColor: secondaryColor10LightTheme,
                  child: FaIcon(FontAwesomeIcons.paperPlane,
                      color: textColorLightTheme),
                ),
              ),
              title: const Text(
                "Set Delivery Location",
                style: TextStyle(color: textColorLightTheme),
              ),
              actions: [
                CircleAvatar(
                  backgroundColor: secondaryColor10LightTheme,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ),
                const SizedBox(width: defaultPadding)
              ],
            ),
            body: Column(
              children: [
                Form(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: TextFormField(
                      onChanged: (value) {
                        if (canSearch) {
                          canSearch = false;

                          placesCubit.getPlaces(searchController.text);
                          Future.delayed(const Duration(milliseconds: 800), () {
                            canSearch = true;
                          });
                        }
                      },
                      controller: searchController,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: "Search your location",
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: FaIcon(FontAwesomeIcons.locationDot,
                              color: textColorLightTheme),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: secondaryColor5LightTheme,
                ),
                const Divider(
                  height: 4,
                  thickness: 4,
                  color: secondaryColor5LightTheme,
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return LocationListTile(
                        press: () {
                          placesCubit.selectPlace(placesCubit.places[index]);
                        },
                        location: placesCubit.places[index],
                      );
                    },
                    itemCount: placesCubit.places.length,
                  ),
                )
              ],
            ),
          );
        },
        listener: (context, state) {
          if (state is GetPlacesErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }

          if (state is SelectPlaceErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }

          if (state is SelectPlaceSuccessState) {
            Navigator.pop(context, state.selectedPlaceModel);
          }
        },
      ),
    );
  }
}
