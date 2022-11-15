import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_map.dart';
import 'package:fwd_map/fwd_map_controller.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

// ignore: must_be_immutable
class FwdMapLocationExample extends StatefulWidget {
  const FwdMapLocationExample({Key? key}) : super(key: key);

  @override
  State<FwdMapLocationExample> createState() => _FwdMapLocationExampleState();
}

class _FwdMapLocationExampleState extends State<FwdMapLocationExample> {
  late FwdMapController _fwdMapController;
  bool locationLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location"),
      ),
      body: FwdMap(
        // "https://map.91.team/styles/basic/style.json",
        trackCameraPosition: true,
        onFwdMapCreated: (fwdMapController) {
          _fwdMapController = fwdMapController;
        },
        onMapLongClick: (position, coordinate) {},
        onCameraIdle: () {},
        onStyleLoadedCallback: () {},
        initialCameraPosition: const CameraPosition(target: LatLng(60.0, 30.0), zoom: 8),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              setState(() => locationLoading = true);
              try {
                final latLng = await _fwdMapController.getUserLocation();
                print(latLng);
                if (latLng != null) {
                  _fwdMapController.animateCamera(
                    CameraUpdate.newLatLngZoom(latLng, 16),
                    duration: const Duration(seconds: 3),
                  );
                }
              } catch (e) {
                print(e);
                setState(() => locationLoading = false);
              }
              setState(() => locationLoading = false);
            },
            child: locationLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.place),
          ),
        ],
      ),
    );
  }
}
