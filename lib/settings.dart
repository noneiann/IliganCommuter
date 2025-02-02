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
      GeoPoint(8.227044833023466, 124.24019661290156),
      GeoPoint(8.228368036424266, 124.2404888573638),
      GeoPoint(8.229525797741116, 124.24066420038952),
      GeoPoint(8.229939163882301, 124.23778789029205),
      GeoPoint(8.231020058762539, 124.23707350331622),
      GeoPoint(8.231589419875833, 124.23376463323429),
      GeoPoint(8.229843683532941, 124.23405170642569),
      GeoPoint(8.228598231374692, 124.23370246891376),
      GeoPoint(8.228432688353333, 124.23659866414089),
      GeoPoint(8.228140060542973, 124.23844075258204),
      GeoPoint(8.227316161479669, 124.2386520663665),
      GeoPoint(8.2270447563471, 124.24021103665571),
      GeoPoint(8.223430913400673, 124.24083537282922),
      GeoPoint(8.217606255449821, 124.2405743296347),
      GeoPoint(8.21432231526774, 124.23664545305782),
      GeoPoint(8.212334609925852, 124.23143506353806),
      GeoPoint(8.212011031998223, 124.22666891248998),
      GeoPoint(8.209597842742765, 124.22012449847766),
      GeoPoint(8.207665234571406, 124.2143952572503),
      GeoPoint(8.204931545886977, 124.20787092256846),
      GeoPoint(8.203403529735091, 124.20248670546677),
      GeoPoint(8.201882149742408, 124.19898591319168),
      GeoPoint(8.200447805557797, 124.19583229412954),
      GeoPoint(8.197200796551469, 124.19128288383288)
    ];



    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Routes')
        .doc('fuentes - city proper');

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
