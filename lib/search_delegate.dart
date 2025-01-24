import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'api.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class RouteSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: JeepneyAPI.fetchRoutes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final routes = JeepneyAPI.routes;

        if (routes.isEmpty) {
          return Center(child: Text('No routes found for "$query".'));
        }

        return ListView.builder(
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            return ListTile(
              title: Text(route.name),
              subtitle: Text('Base Fare: ${route.baseFare} PHP'),
              onTap: () {
                close(context, route);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: JeepneyAPI.fetchRoutes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final routes = JeepneyAPI.routes;

        if (routes.isEmpty) {
          return Center(child: Text('No routes found for "$query".'));
        }

        return ListView.builder(
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            return ListTile(
              title: Text(route.name),
              subtitle: Text('Base Fare: ${route.baseFare} PHP'),
              onTap: () {
                close(context, route);
              },
            );
          },
        );
      },
    );
  }}
