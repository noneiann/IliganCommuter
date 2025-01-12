// api.dart
class RouteInfo {
  final String name;
  final double baseFare;

  const RouteInfo(this.name, this.baseFare);
}

class JeepneyAPI {
  static const List<RouteInfo> routes = [
    RouteInfo('Buruun - City Proper', 12.00),
    RouteInfo('Tambacan - City Proper', 12.00),
    RouteInfo('Tubod - City Proper', 15.00),
    RouteInfo('Tibanga - City Proper', 12.00),
    RouteInfo('Pala-o - City Proper', 12.00),
  ];

  static double calculateFare(String routeName, String passengerType) {
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
  }
}