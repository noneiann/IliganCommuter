import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

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

    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('locations')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    setState(() {
      _markers.clear();
    });

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lat = data['latitude'];
      final lng = data['longitude'];
      final name = data['name'];

      if (lat != null && lng != null) {
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
            ),
          );
        });
      }
    }

    if (_markers.isNotEmpty) {
      final firstMarker = _markers.first;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(firstMarker.position),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Locations'),
      ),
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
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(8.236027784454347, 124.24716842775479), // Default initial position
                zoom: 15,
              ),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}