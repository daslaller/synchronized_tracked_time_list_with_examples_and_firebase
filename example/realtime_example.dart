import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A client-side listener that displays real-time updates from Firestore.
class RealtimeStatusDisplay {
  final CollectionReference _collection;
  StreamSubscription? _subscription;

  RealtimeStatusDisplay({required CollectionReference collection}) : _collection = collection {
    _listenForUpdates();
  }

  void _listenForUpdates() {
    print("📡 (Client) Listening for real-time updates...");
    _subscription = _collection.snapshots().listen((querySnapshot) {
      if (querySnapshot.docChanges.isEmpty) return;

      for (final change in querySnapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final phoneId = data['id'];
        final status = data['status'];

        switch (change.type) {
          case DocumentChangeType.added:
            print("✨ (Client) NEW: Phone number $phoneId just became active!");
            break;
          case DocumentChangeType.modified:
            print("🔄 (Client) UPDATE: Status for $phoneId changed to '$status'.");
            break;
          case DocumentChangeType.removed:
            print("🗑️ (Client) DELETED: The record for $phoneId was removed.");
            break;
        }
      }
    }, onError: (error) {
      print("Error listening to client stream: $error");
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}