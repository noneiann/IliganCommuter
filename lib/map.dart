import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'api.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LocationData? currentLocation;

  void getCurrentLocation (){
    Location location = Location();

    location.getLocation().then((location) {
      currentLocation = location;
    });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      setState(() {

      });
    });
  }

@override
  void initState() {
    getCurrentLocation();
    super.initState();
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _searchLocations() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Fetch routes using JeepneyAPI
    await JeepneyAPI.fetchRoutes(query);

    setState(() {
      _polylines.clear();
    });

    for (var route in JeepneyAPI.routes) {
      final points = route.points;

      if (points.isNotEmpty) {
        // Fetch the road-following path using the Directions API
        final roadPolyline = await _getRoadPolyline(points);

        if (roadPolyline.isNotEmpty) {
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: PolylineId(route.name),
                points: roadPolyline,
                color: Colors.blue,
                width: 5,
              ),
            );
          });

          // Adjust camera to fit the polyline
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              _getLatLngBounds(roadPolyline),
              50.0, // Padding
            ),
          );
        }
      }
    }
  }
// Function to fetch road-following polyline from Directions API
  Future<List<LatLng>> _getRoadPolyline(List<LatLng> waypoints) async {
    if (waypoints.isEmpty) return [];

    const String googleApiKey = 'AIzaSyCdQSBnFQOwzzVj5tFiCHDgTWKYkILzb70';
    PolylinePoints polylinePoints = PolylinePoints();

    // Build the API URL
    String origin = '${waypoints.first.latitude},${waypoints.first.longitude}';
    String destination = '${waypoints.last.latitude},${waypoints.last.longitude}';
    String waypointString = waypoints
        .skip(1) // Skip the first point (origin)
        .take(waypoints.length - 2) // Skip the last point (destination)
        .map((point) => '${point.latitude},${point.longitude}')
        .join('|');

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&waypoints=$waypointString&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final encodedPolyline =
          data['routes'][0]['overview_polyline']['points'];
          List<PointLatLng> decodedPolyline =
          polylinePoints.decodePolyline(encodedPolyline);

          return decodedPolyline
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }

    return [];
  }

// Helper function to calculate LatLngBounds
  LatLngBounds _getLatLngBounds(List<LatLng> points) {
    double? south, north, west, east;
    for (LatLng point in points) {
      if (south == null || point.latitude < south) south = point.latitude;
      if (north == null || point.latitude > north) north = point.latitude;
      if (west == null || point.longitude < west) west = point.longitude;
      if (east == null || point.longitude > east) east = point.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(south!, west!),
      northeast: LatLng(north!, east!),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for a location...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocations,
                ),
              ],
            ),
          ),
          Expanded(
            child: currentLocation == null ? Center(child: Text("Loading"),) : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!), // Default position
                zoom: 15,
              ),
              polylines: _polylines, // Add polylines to the map
              markers: {
                Marker(
                  markerId: const MarkerId("currentLocation"),
                  position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),

                )
              }
            ),

          ),
        ],
      ),
    );
  }
}