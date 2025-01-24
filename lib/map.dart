import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'api.dart';
import './search_delegate.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FloatingSearchBarController _searchController = FloatingSearchBarController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LocationData? currentLocation;
  bool _isLoading = false;

  List<RouteInfo> _searchResults = [];

  void _performSearch(String query) {
    setState(() {
      _isLoading = true;
    });

    JeepneyAPI.searchRoutes(query).then((results) {
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    });
  }

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

  void _initializeRoutes() {
    setState(() {
      _isLoading = true;
    });

    JeepneyAPI.fetchAllRoutes().then((_) {
      setState(() {
        _searchResults = JeepneyAPI.routes;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    });
  }

@override
  void initState() {
    getCurrentLocation();
    _initializeRoutes();

    super.initState();

  }


  @override
  void dispose() {
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _searchRoute() async {
    final selectedRoute = await showSearch(
      context: context,
      delegate: RouteSearchDelegate(),
    );

    if (selectedRoute != null && selectedRoute is RouteInfo) {
      // Clear existing polylines
      setState(() {
        _polylines.clear();
      });

      // Draw the route polyline
      final roadPolyline = await _getRoadPolyline(selectedRoute.points);
      if (roadPolyline.isNotEmpty) {
        setState(() {
          _polylines.add(
            Polyline(
              polylineId: PolylineId(selectedRoute.name),
              points: roadPolyline,
              color: Colors.blue,
              width: 5,
            ),
          );
        });

        // Adjust camera to fit the route
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            _getLatLngBounds(roadPolyline),
            50.0, // Padding
          ),
        );
      }
    }
  }

  void _selectRoute(RouteInfo route) {

    _searchController.close();


    // Clear existing polylines
    setState(() {
      _polylines.clear();
    });

    // Draw route on map
    _drawRouteOnMap(route);
  }

  Future<void> _drawRouteOnMap(RouteInfo route) async {
    try {
      final roadPolyline = await _getRoadPolyline(route.points);

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

        // Adjust camera to fit the route
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            _getLatLngBounds(roadPolyline),
            50.0, // Padding
          ),
        );
      }
    } catch (e) {
      print('Error drawing route: $e');
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildMap(),
          // Search bar on top of the map
          buildFloatingSearchBar()
        ],
      ),
    );
  }


  Widget buildMap(){
    return
      currentLocation == null
          ? const Center(child: Text("Loading"))
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            currentLocation!.latitude!,
            currentLocation!.longitude!,
          ),
          zoom: 15,
        ),
        polylines: _polylines, // Add polylines to the map
        markers: {
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: LatLng(
              currentLocation!.latitude!,
              currentLocation!.longitude!,
            ),
          ),
        },
      );
  }

  Widget buildSearch(){
    return Positioned(
      top: 20.0,
      left: 10.0,
      right: 10.0,
      child: GestureDetector(
        onTap: _searchRoute, // Trigger the search delegate
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8.0),
              Text(
                "Search for a location...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildFloatingSearchBar() {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return FloatingSearchBar(
      controller: _searchController,
      hint: 'Search Routes...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        _performSearch(query);
      },
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: _buildSearchResults(),
          ),
        );
      },
    );
  }
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No routes found'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final route = _searchResults[index];
        return ListTile(
          title: Text(route.name),
          subtitle: Text('Base Fare: ₱${route.baseFare.toStringAsFixed(2)}'),
          onTap: () => _selectRoute(route),
        );
      },
    );
  }


  }