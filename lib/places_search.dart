import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'api.dart';
import 'package:http/http.dart' as http;

class RouteSearchPage extends StatefulWidget {
  static const String searchHeroTag = 'search-bar-tag';
  const RouteSearchPage({super.key});

  @override
  State<RouteSearchPage> createState() => _RouteSearchPageState();
}

class _RouteSearchPageState extends State<RouteSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<RouteInfo> filteredRoutes = [];
  List<dynamic> listOfLocations = [];
  final token = "123456789";

  // Indicators for search status.
  bool _isSearchingPlaces = false;
  bool _isSearchingRoutes = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    filteredRoutes = []; // Start with empty routes
  }

  Future<LatLng?> getPlaceDetails(String placeId) async {
    const String apiKey = "AIzaSyCdQSBnFQOwzzVj5tFiCHDgTWKYkILzb70";
    final String detailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(detailsUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final location = data['result']['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
    return null;
  }

  void placeSuggestion(String input) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (input.isEmpty) {
        setState(() {
          listOfLocations = [];
          filteredRoutes = [];
        });
        return;
      }

      const String apiKey = "AIzaSyCdQSBnFQOwzzVj5tFiCHDgTWKYkILzb70";
      const String baseUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";

      try {
        // Start indicator for place search.
        setState(() {
          _isSearchingPlaces = true;
        });
        final response = await http.get(
          Uri.parse('$baseUrl?input=iligan $input&key=$apiKey'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            listOfLocations = data['predictions'];
            filteredRoutes = []; // Clear previous routes when searching
          });
        }
      } catch (e) {
        print(e.toString());
      } finally {
        setState(() {
          _isSearchingPlaces = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine header text based on the state.
    String headerText;
    if (_isSearchingPlaces) {
      headerText = 'Searching for places...';
    } else if (listOfLocations.isNotEmpty) {
      headerText = 'Place Suggestions';
    } else if (filteredRoutes.isNotEmpty) {
      headerText = 'Nearby Routes';
    } else {
      headerText = 'Results';
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Field Container with updated hint text.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Hero(
                      tag: RouteSearchPage.searchHeroTag,
                      child: Material(
                        color: Colors.transparent,
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search for places...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          onChanged: placeSuggestion,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Header above the results list.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              child: Text(
                headerText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Results List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: listOfLocations.isNotEmpty
                    ? listOfLocations.length
                    : filteredRoutes.length,
                separatorBuilder: (context, index) =>
                const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (listOfLocations.isNotEmpty) {
                    // Display place suggestions.
                    final place = listOfLocations[index];
                    return ListTile(
                      textColor: Theme.of(context).colorScheme.onSurface,
                      iconColor: Theme.of(context).colorScheme.primary,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        place["description"],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        // Start indicator for nearby route search.
                        setState(() {
                          _isSearchingRoutes = true;
                        });
                        final placeId = place["place_id"];
                        final latLng = await getPlaceDetails(placeId);
                        if (latLng != null) {
                          final nearbyRoutes =
                          JeepneyAPI.findRoutesNearLocation(latLng);
                          setState(() {
                            filteredRoutes = nearbyRoutes;
                            listOfLocations = [];
                          });
                        }
                        // End indicator.
                        setState(() {
                          _isSearchingRoutes = false;
                        });
                      },
                    );
                  } else {
                    // Display nearby routes.
                    final route = filteredRoutes[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        route.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Base Fare: ₱${route.baseFare.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        Navigator.pop(context, route);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
