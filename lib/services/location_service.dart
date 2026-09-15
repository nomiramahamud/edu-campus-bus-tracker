import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // IMPORTANT: this project's Realtime Database lives in asia-southeast1,
  // not the default us-central1. FirebaseDatabase.instance assumes the
  // default region and gets its connection killed by the server as a
  // result (silently — no exception is thrown, so streams just never
  // emit). Must use instanceFor() with the explicit databaseURL.
  final DatabaseReference _liveLocationsRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    'https://edu-bus-tracker-5aca1-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref('liveLocations');

  // Request permission and get the device's current position
  // (used later for driver-side apps, or for "distance to stop" features)
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  // Write a bus's live location (called from a driver-side app or a simulator)
  Future<void> updateBusLocation({
    required String busId,
    required double latitude,
    required double longitude,
  }) async {
    await _liveLocationsRef.child(busId).set({
      'lat': latitude,
      'lng': longitude,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Stream a single bus's live location (used on rider's map screen)
  Stream<Map<String, dynamic>?> streamBusLocation(String busId) {
    return _liveLocationsRef.child(busId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      return Map<String, dynamic>.from(data as Map);
    });
  }

  // Stream ALL live bus locations at once (used on the "See map" screen)
  Stream<Map<String, dynamic>> streamAllBusLocations() {
    return _liveLocationsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return {};
      return Map<String, dynamic>.from(data as Map);
    });
  }

  // Seed sample bus locations for development/demo
  Future<void> seedSampleBusLocations() async {
    final sampleLocations = {
      'bus1': {
        'lat': 22.3456,
        'lng': 91.8123,
        'updatedAt': ServerValue.timestamp,
      },
      'bus2': {
        'lat': 22.3569,
        'lng': 91.7832,
        'updatedAt': ServerValue.timestamp,
      },
    };

    try {
      for (final entry in sampleLocations.entries) {
        await _liveLocationsRef.child(entry.key).set({
          'lat': entry.value['lat'],
          'lng': entry.value['lng'],
          'updatedAt': ServerValue.timestamp,
        });
      }
      debugPrint('✅ Seeded ${sampleLocations.length} sample bus locations');
    } catch (e) {
      debugPrint('❌ Failed to seed locations: $e');
    }
  }
}