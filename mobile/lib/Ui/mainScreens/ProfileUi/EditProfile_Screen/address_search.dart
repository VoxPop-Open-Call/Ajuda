import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';

class AddressSearch extends StatefulWidget {
  static const String route = "AddressSearch";

  const AddressSearch({super.key});

  @override
  _AddressSearchState createState() => _AddressSearchState();
}

class _AddressSearchState extends State<AddressSearch> {

  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SearchGooglePlacesWidget(
          apiKey: 'MAPS_API_KEY',
          // The language of the autocompletion
          language: 'en',
          // The position used to give better recommendations. In this case we are using the user position
          // radius: 30000,

          onSelected: (Place place) async {
            final geolocation = await place.geolocation;

            // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(
                CameraUpdate.newLatLng(geolocation!.coordinates));
            controller.animateCamera(
                CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
          },
          onSearch: (Place place) {},
        ),
      ),
    );
  }
}
