import 'dart:math';

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
  static List<RouteInfo> searchResults = [];


  static Future<void> fetchAllRoutes() async {
    try {
      final snapshot = await _firestore.collection('Routes').get();
      routes = snapshot.docs.map((doc) {
        final data = doc.data();
        final points = (data['points'] as List?)?.map((point) {
          if (point is GeoPoint) {
            return LatLng(point.latitude, point.longitude);
          } else {
            // Handle unexpected data types (e.g., maps or null)
            return LatLng(0.0, 0.0); // Default value
          }
        }).toList() ?? [];
        print(data);
        return RouteInfo(data['name'], data['basefare'].toDouble(),points);
      }).toList();
    } catch (e) {
      print('Error fetching routes: $e');
    }
  }

  static Future<List<RouteInfo>> searchRoutes(String query) async {
    try {
      print('Search Query: "$query"');

      if (query.isEmpty) {
        print('Query is empty, fetching all routes');
        await fetchAllRoutes();
        print('Total routes: ${routes.length}');
        return routes;
      }

      // Fetch all routes first
      await fetchAllRoutes();

      // Filter routes manually
      final filteredRoutes = routes.where((route) {
        final matchesQuery = route.name.toLowerCase().contains(query.toLowerCase());
        print('Route: ${route.name}, Matches Query: $matchesQuery');
        return matchesQuery;
      }).toList();

      print('Filtered Routes Count: ${filteredRoutes.length}');

      return filteredRoutes;
    } catch (e) {
      print('Error in searchRoutes: $e');
      return [];
    }
  }
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



  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371e3; // meters
    final lat1 = point1.latitude * (pi / 180);
    final lon1 = point1.longitude * (pi / 180);
    final lat2 = point2.latitude * (pi / 180);
    final lon2 = point2.longitude * (pi / 180);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static List<RouteInfo> findRoutesNearLocation(LatLng target, {double maxDistance = 1000}) {
    List<RouteInfo> nearbyRoutes = [];
    for (var route in routes) {
      bool isNearby = false;
      for (var point in route.points) {
        final distance = calculateDistance(target, point);
        if (distance <= maxDistance) {
          isNearby = true;
          break;
        }
      }
      if (isNearby) nearbyRoutes.add(route);
    }
    return nearbyRoutes;
  }

  static double calculateTotalDistance(List<LatLng> points) {
    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += calculateDistance(points[i], points[i + 1]);
    }
    return totalDistance;
  }

  static double calculateFare(String routeName, String passengerType) {
    try {
      final route = routes.firstWhere((r) => r.name == routeName);
      final double distanceKm = calculateTotalDistance(route.points) / 1000;

      // Fare calculation
      double fare = 13.0;
      if (distanceKm > 4) {
        fare += (distanceKm - 4).ceil(); // Round up to nearest whole kilometer
      }

      // Apply discounts
      if (passengerType == 'Student' || passengerType == 'Senior') {
        fare -= 2.0;
      }

      return fare.clamp(0.0, double.infinity); // Ensure non-negative fare
    } catch (e) {
      print('Error calculating fare: $e');
      return 0.0;
    }
  }

}