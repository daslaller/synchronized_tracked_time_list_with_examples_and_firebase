/// Attention!!! Realtime examples cant work without the cloud_firestore in packages 
/// and having the sdk for flutter installed. Therefore the example is commented out.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeClientListener {
  final CollectionReference _collection;
  StreamSubscription? _subscription;

  RealtimeClientListener({required CollectionReference collection}) : _collection = collection {
    _listenForUpdates();
  }

  void _listenForUpdates() {
    print("📡 Client is now listening for real-time updates...");
    _subscription = _collection.snapshots().listen((querySnapshot) {
      if (querySnapshot.docChanges.isEmpty) return;

      for (final change in querySnapshot.docChanges) {
        final data = change.doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final docId = change.doc.id;
        final status = data['syncStatus']; // 'active', 'removed', 'expired'

        switch (change.type) {
          case DocumentChangeType.added:
            print("✨ Client SAW ADD: Document '$docId' created with status '$status'.");
            break;
          case DocumentChangeType.modified:
            print("🔄 Client SAW MODIFY: Document '$docId' updated to status '$status'.");
            break;
          case DocumentChangeType.removed:
            print("🗑️ Client SAW DELETE: Document '$docId' was removed.");
            break;
        }
      }
    }, onError: (error) {
      print("Error listening to client stream: $error");
    });
  }

  void dispose() {
    _subscription?.cancel();
    print("Client listener stopped.");
  }
}