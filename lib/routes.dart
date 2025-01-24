// routes.dart
import 'package:flutter/material.dart';
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
    // TODO: implement initState
    JeepneyAPI.fetchAllRoutes();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Route Selection
          DropdownButtonFormField<String>(
            value: selectedRoute,
            decoration: const InputDecoration(
              labelText: 'Select Route',
              border: OutlineInputBorder(),
            ),
            items: JeepneyAPI.routes.map((route) {
              return DropdownMenuItem(
                value: route.name,
                child: Text(route.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedRoute = value;
                fare = JeepneyAPI.calculateFare(selectedRoute!, passengerType);
              });
            },
          ),
          const SizedBox(height: 16),

          // Passenger Type Selection
          Card(
            child: Column(
              children: [
                RadioListTile(
                  title: const Text('Regular'),
                  value: 'Regular',
                  groupValue: passengerType,
                  onChanged: (value) {
                    setState(() {
                      passengerType = value.toString();
                      if (selectedRoute != null) {
                        fare = JeepneyAPI.calculateFare(selectedRoute!, passengerType);
                      }
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Student'),
                  value: 'Student',
                  groupValue: passengerType,
                  onChanged: (value) {
                    setState(() {
                      passengerType = value.toString();
                      if (selectedRoute != null) {
                        fare = JeepneyAPI.calculateFare(selectedRoute!, passengerType);
                      }
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Senior Citizen'),
                  value: 'Senior',
                  groupValue: passengerType,
                  onChanged: (value) {
                    setState(() {
                      passengerType = value.toString();
                      if (selectedRoute != null) {
                        fare = JeepneyAPI.calculateFare(selectedRoute!, passengerType);
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (fare != null)
            Card(
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
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )

        ],
      ),
    );
  }
}