import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  static const geopoints = [
    { 'latitude': 8.319188626178077, 'longitude': 124.24888306219502 },
    { 'latitude': 8.3139554471555, 'longitude': 124.251492309312 },
    { 'latitude': 8.311606243247569, 'longitude': 124.2527730098324 },
    { 'latitude': 8.309719154038119, 'longitude': 124.2537459115727 },
    { 'latitude': 8.308254160178773, 'longitude': 124.25455212668767 }
  ];

  Future<void> addPointsToDocument() async {
    final points = [
      GeoPoint(8.226411927879289, 124.24011839373422),
      GeoPoint(8.227837000752118, 124.24056109316142),
      GeoPoint(8.228137400101703, 124.24422921540607),
      GeoPoint(8.228322139170249, 124.24245309022626),
      GeoPoint(8.22875337849349, 124.23947008801103),
      GeoPoint(8.22970636673091, 124.23775103266159),
      GeoPoint(8.231078304081011, 124.23629457695897),
      GeoPoint(8.230493800844076, 124.23362156362718),
      GeoPoint(8.229096595561584, 124.23376668343244),
      GeoPoint(8.228458097050765, 124.23635311862948),
      GeoPoint(8.227652234445289, 124.23901353973972),
      GeoPoint(8.227541463429164, 124.23981851117026),
      GeoPoint(8.226928236540891, 124.23969733019621),
      GeoPoint(8.226325388515589, 124.24009556562282),
      GeoPoint(8.220568599074133, 124.2416746881601),
      GeoPoint(8.211332008050439, 124.24556015082199),

    ];



    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Routes')
        .doc('baraas - city proper');

    await docRef.update({
      'points': points
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
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
                  'Set your preferences here',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.language),
          title: Text('Language'),
          subtitle: Text('English'),
        ),
        const ListTile(
          leading: Icon(Icons.dark_mode),
          title: Text('Theme'),
          subtitle: Text('Light'),
        ),
        const ListTile(
          leading: Icon(Icons.info),
          title: Text('About'),
          subtitle: Text('Version 1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.icecream),
          title: const Text('Batch Add Routes'),
          subtitle: const Text('DEBUG: Add routes to specified code'),
          onTap: (){
            addPointsToDocument();
          },
        )
      ],
    );
  }
}
