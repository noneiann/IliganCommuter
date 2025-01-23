import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // For LatLng

class RouteInfo {
  final String name;
  final double baseFare;
  final List<LatLng> points;

  RouteInfo(this.name, this.baseFare, this.points);
}

class JeepneyAPI {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static List<RouteInfo> routes = [];

  static Future<void> fetchRoutes(String query) async {
    try {
      final snapshot = await _firestore
          .collection('Routes')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      routes = snapshot.docs.map((doc) {
        final data = doc.data();

        // Handle null or missing fields
        final name = data['name'] as String? ?? 'Unnamed Route';
        final baseFare = (data['baseFare'] as num?)?.toDouble() ?? 0.0;

        // Handle GeoPoint objects in the 'points' field
        final points = (data['points'] as List?)?.map((point) {
          if (point is GeoPoint) {
            return LatLng(point.latitude, point.longitude);
          } else {
            // Handle unexpected data types (e.g., maps or null)
            return LatLng(0.0, 0.0); // Default value
          }
        }).toList() ?? [];

        return RouteInfo(name, baseFare, points);
      }).toList();
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  static double calculateFare(String routeName, String passengerType) {
    try {
      final route = routes.firstWhere((r) => r.name == routeName);
      double fare = route.baseFare;

      switch (passengerType) {
        case 'Student':
          fare *= 0.8; // 20% discount
          break;
        case 'Senior':
          fare *= 0.8; // 20% discount
          break;
        default:
          break;
      }

      return fare;
    } catch (e) {
      print('Error calculating fare: $e');
      return 0.0; // Default fare if route is not found
    }
  }
}