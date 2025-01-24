import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add google_fonts package to pubspec.yaml
import 'api.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  String? selectedRoute;
  String passengerType = 'Regular';
  double? fare;

  @override
  void initState() {
    JeepneyAPI.fetchAllRoutes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Custom Header
        Container(
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
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Find your route and fare easily',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),


        // Rest of the Page
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Route Selection
                DropdownButtonFormField<String>(
                  value: selectedRoute,
                  dropdownColor: Theme.of(context).colorScheme.onPrimaryContainer,

                  decoration: InputDecoration(
                    labelText: 'Select Route',
                    labelStyle: GoogleFonts.poppins(color: Colors.black87),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),

                    ),
                  ),
                  items: JeepneyAPI.routes.map((route) {
                    return DropdownMenuItem(
                      value: route.name,
                      child: Text(
                        route.name,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoute = value;
                      fare = JeepneyAPI.calculateFare(selectedRoute!, passengerType);
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Passenger Type Selection
                DropdownButtonFormField<String>(
                  value: passengerType,
                  dropdownColor: Theme.of(context).colorScheme.onPrimaryContainer,

                  decoration: InputDecoration(
                    labelText: 'Select Passenger Type',
                    labelStyle: GoogleFonts.poppins(color: Colors.black87),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),

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
                        fare = JeepneyAPI.calculateFare(selectedRoute!, passengerType);
                      }
                    });
                  },
                ),
                const SizedBox(height: 24),


                if (fare != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Fare Amount',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₱${fare!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF98D8D8), // Accent blue
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
