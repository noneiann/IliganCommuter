import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iliganon_go/places_search.dart';
import 'api.dart';
import 'places_search.dart';
import 'map.dart'; // Import MapPage to navigate to it

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  // Store full route information here.
  RouteInfo? selectedRouteInfo;
  String? selectedRoute;
  String passengerType = 'Regular';
  double? fare;
  bool isLoading = true;

  @override
  void initState() {
    initRoutes();
    super.initState();
  }

  Future<void> initRoutes() async {
    await JeepneyAPI.fetchAllRoutes();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildHeader(),
        isLoading
            ? const Center(child: Text("Loading..."))
            : Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Route Selection Field
                Hero(
                  tag: RouteSearchPage.searchHeroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        readOnly: true,
                        onTap: () async {
                          final result = await Navigator.push<RouteInfo>(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                              const Duration(milliseconds: 400),
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const RouteSearchPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              selectedRoute = result.name;
                              selectedRouteInfo = result;
                              fare = JeepneyAPI.calculateFare(
                                  result.name, passengerType);
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: selectedRoute ?? 'Search Places...',
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Passenger Type Selection
                DropdownButtonFormField<String>(
                  value: passengerType,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  decoration: InputDecoration(
                    labelText: 'Select Passenger Type',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  items: ['Regular', 'Student', 'Senior'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      passengerType = value!;
                      if (selectedRoute != null) {
                        fare = JeepneyAPI.calculateFare(
                            selectedRoute!, passengerType);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Fare Card and "View Route on Map" Button
                if (fare != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Theme.of(context).colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Fare Amount',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₱${fare!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          if (selectedRouteInfo != null) {
                            // Navigate to MapPage and pass the selected route.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(
                                  route: selectedRouteInfo,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text("View Route on Map"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_bus_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Text(
                  'Iliganon Go!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Find your route and fare easily',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
