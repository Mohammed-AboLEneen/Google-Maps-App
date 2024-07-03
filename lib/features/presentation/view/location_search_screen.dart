import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_app/features/presentation/view_model/places_cubit/places_cubit.dart';

import '../../../constants.dart';
import '../../../cores/widgets/location_list_tile.dart';
import '../view_model/places_cubit/places_states.dart';

class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final TextEditingController searchController = TextEditingController();

  bool canSearch = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlacesCubit(),
      child: BlocConsumer<PlacesCubit, PlacesStates>(
        builder: (context, state) {
          PlacesCubit placesCubit = PlacesCubit.get(context);

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

          if (state is SelectPlaceSuccessState) {
            Navigator.pop(context, state.location);
          }
        },
      ),
    );
  }
}
