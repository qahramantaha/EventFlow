import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMap;

  Future<void> _onMapCreated(MapboxMap map) async {
    mapboxMap = map;

    await mapboxMap!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(-8.2, 53.4),
        ),
        zoom: 5.2,
      ),
    );

    await mapboxMap!.setBounds(
      CameraBoundsOptions(
        bounds: CoordinateBounds(
          southwest: Point(coordinates: Position(-10.8, 51.3)),
          northeast: Point(coordinates: Position(-5.3, 55.6)),
          infiniteBounds: false,
        ),
        minZoom: 4.5,
        maxZoom: 14.0,
      ),
    );

    await mapboxMap!.gestures.updateSettings(
      GesturesSettings(
        scrollEnabled: true,
        pinchToZoomEnabled: true,
        doubleTapToZoomInEnabled: true,
        quickZoomEnabled: true,
        rotateEnabled: false,
        pitchEnabled: false,
        simultaneousRotateAndPinchToZoomEnabled: false,
        pinchPanEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        automaticallyImplyLeading: false,
      ),
      body: MapWidget(
        onMapCreated: _onMapCreated,
      ),
    );
  }
}