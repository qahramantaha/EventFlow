import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        centerTitle: true,
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        onMapCreated: (MapboxMap map) async {
          mapboxMap = map;

          await mapboxMap!.setCamera(
            CameraOptions(
              center: Point(
                coordinates: Position(-8.0, 53.4),
              ),
              zoom: 5.5,
            ),
          );

          await mapboxMap!.setBounds(
            CameraBoundsOptions(
              bounds: CoordinateBounds(
                southwest: Point(
                  coordinates: Position(-10.8, 51.3),
                ),
                northeast: Point(
                  coordinates: Position(-5.3, 55.6),
                ),
                infiniteBounds: false,
              ),
              minZoom: 5.0,
              maxZoom: 16.0,
            ),
          );
        },
      ),
    );
  }
}