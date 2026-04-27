import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'models/event_models.dart';
import 'services/event_services.dart';
import 'user_session.dart';
import 'package:url_launcher/url_launcher.dart';
import 'event_details_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapboxMap? mapboxMap;
  CircleAnnotationManager? circleAnnotationManager;

  final List<EventModel> events = [];
  final Map<String, EventModel> annotationEvents = {};

  EventModel? selectedEvent;

  Future<void> openRouteToEvent(EventModel event) async {
  final encodedLocation = Uri.encodeComponent(event.location);

  final Uri url = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$encodedLocation',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('Could not open maps');
    } 
  }

  int getColorForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'sports':
      return 0xFF4CAF50; 
    case 'academic':
      return 0xFF2196F3;
    case 'social':
      return 0xFF9C27B0; 
    default:
      return 0xFFE53935; 
  }
}
  Widget mapLegend() {
  return Positioned(
    top: 20,
    right: 16,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Legend",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),

          Row(
            children: [
              Icon(Icons.circle, color: Color(0xFF4CAF50), size: 12),
              SizedBox(width: 6),
              Text("Sports"),
            ],
          ),

          Row(
            children: [
              Icon(Icons.circle, color: Color(0xFF2196F3), size: 12),
              SizedBox(width: 6),
              Text("Academic"),
            ],
          ),

          Row(
            children: [
              Icon(Icons.circle, color: Color(0xFF9C27B0), size: 12),
              SizedBox(width: 6),
              Text("Social"),
            ],
          ),
        ],
      ),
    ),
  );
}

int currentStyleIndex = 0;
bool showStyleOptions = false;

final List<String> mapStyles = [
  MapboxStyles.MAPBOX_STREETS,     
  MapboxStyles.DARK,                
  MapboxStyles.SATELLITE_STREETS, 
];

final List<IconData> styleIcons = [
  Icons.light_mode,
  Icons.dark_mode,
  Icons.satellite,
];

void cycleMapStyle() async {
  if (mapboxMap == null) return;

  setState(() {
    currentStyleIndex = (currentStyleIndex + 1) % mapStyles.length;
  });

  await mapboxMap!.loadStyleURI(mapStyles[currentStyleIndex]);
}

Widget mapStylePanel() {
  return Positioned(
    top: 100,
    left: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          mini: true,
          onPressed: () {
            setState(() {
              showStyleOptions = !showStyleOptions;
            });
          },
          child: const Icon(Icons.layers),
        ),

        const SizedBox(height: 8),

        if (showStyleOptions)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                _styleOption("Light", MapboxStyles.MAPBOX_STREETS, Icons.light_mode),
                _styleOption("Dark", MapboxStyles.DARK, Icons.dark_mode),
                _styleOption("Satellite", MapboxStyles.SATELLITE_STREETS, Icons.satellite),
              ],
            ),
          ),
      ],
    ),
  );
}

String selectedCategoryFilter = "All";

final List<String> categoryFilters = [
  "All",
  "Sports",
  "Academic",
  "Social",
];

Widget filterMenuButton() {
  return Positioned(
    top: 20,
    left: 16,
    child: PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: (value) async {
        setState(() {
          selectedCategoryFilter = value;
        });

        await addEventPins();
      },
      itemBuilder: (context) => [
        _filterItem("All"),
        _filterItem("Sports"),
        _filterItem("Academic"),
        _filterItem("Social"),
      ],
    ),
  );
}

PopupMenuItem<String> _filterItem(String value) {
  return PopupMenuItem(
    value: value,
    child: Row(
      children: [
        if (selectedCategoryFilter == value)
          const Icon(Icons.check, size: 18),
        if (selectedCategoryFilter == value)
          const SizedBox(width: 6),
        Text(value),
      ],
    ),
  );
}

Widget _styleOption(String label, String style, IconData icon) {
  return TextButton.icon(
    onPressed: () async {
      if (mapboxMap == null) return;

      await mapboxMap!.loadStyleURI(style);

      setState(() {
        showStyleOptions = false; 
      });
    },
    icon: Icon(icon, size: 18),
    label: Text(label),
  );
  
}
  Future<void> _onMapCreated(MapboxMap map) async {
    mapboxMap = map;

    await mapboxMap!.loadStyleURI(mapStyles[currentStyleIndex]);

    mapboxMap!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(-9.0491, 53.2743),
        ),
        zoom: 11.0,
      ),
    );

    mapboxMap!.gestures.updateSettings(
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

    circleAnnotationManager =
        await mapboxMap!.annotations.createCircleAnnotationManager();

    circleAnnotationManager!.tapEvents(
      onTap: (CircleAnnotation annotation) {
        setState(() {
          selectedEvent = annotationEvents[annotation.id];
        });
      },
    );

    await loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final loadedEvents = await EventService.getEvents(UserSession.id);

      events.clear();
      events.addAll(loadedEvents);

      debugPrint('Loaded events: ${events.length}');
      for (final event in events) {
        debugPrint('Event: ${event.title} | Location: ${event.location}');
      }

      await addEventPins(); 
    } catch (e) {
      debugPrint('Failed to load events: $e');
    }
  }

  Future<Point?> getPointFromLocation(String location) async {
    const accessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

    final url = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(location)}.json'
      '?access_token=$accessToken'
      '&country=ie'
      '&limit=1',
    );

    final response = await http.get(url);

    debugPrint('Geocoding: $location');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['features'] != null && data['features'].isNotEmpty) {
        final coordinates = data['features'][0]['center'];

        return Point(
          coordinates: Position(
            coordinates[0],
            coordinates[1],
          ),
        );
      }
    }

    return null;
  }

  Future<void> addEventPins() async {
    if (circleAnnotationManager == null) return;

    circleAnnotationManager!.deleteAll();
    annotationEvents.clear();

    for (final event in events) {
      if (selectedCategoryFilter != "All" &&
        event.category.toLowerCase() != selectedCategoryFilter.toLowerCase()) {
      continue;
}
      final point = await getPointFromLocation(event.location);

      if (point == null) {
        debugPrint('Could not find location: ${event.location}');
        continue;
      }

      final annotation = await circleAnnotationManager!.create(
        CircleAnnotationOptions(
          geometry: point,
          circleRadius: 9.0,
          circleColor: getColorForCategory(event.category),
          circleStrokeWidth: 2.0,
          circleStrokeColor: 0xFFFFFFFF,
        ),
      );

      annotationEvents[annotation.id] = event;
    }
  }

  Widget eventDetailsCard() {
    if (selectedEvent == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedEvent!.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text('${selectedEvent!.date} at ${selectedEvent!.time}'),
              const SizedBox(height: 6),
              Text(selectedEvent!.location),
              const SizedBox(height: 6),
              Text(selectedEvent!.description),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(
                            eventId: selectedEvent!.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Event'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedEvent = null;
                      });
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      body: Stack(
        children: [
          MapWidget(
            onMapCreated: _onMapCreated,
          ),
          mapStylePanel(),
          mapLegend(),
          eventDetailsCard(),
          filterMenuButton(),
        ],
      ),
    );
  }
}