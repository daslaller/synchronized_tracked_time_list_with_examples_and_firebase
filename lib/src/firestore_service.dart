import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchronized_tracked_time_list/src/synchronized_tracked_set_gemini.dart';

/// A service to sync events from a TimedList to a Firestore collection.
class FirestoreSyncService<T> {
  final SynchronizedTrackedTimeSet<T> _timedList;
  final CollectionReference _collection;
  final String Function(T item) _idFromItem;
  StreamSubscription? _subscription;

  FirestoreSyncService({
    required SynchronizedTrackedTimeSet<T> timedList,
    required CollectionReference collection,
    required String Function(T item) idFromItem,
  })  : _timedList = timedList,
        _collection = collection,
        _idFromItem = idFromItem {
    _listenToEvents();
  }

  void _listenToEvents() {
    _subscription = _timedList.events.listen((payload) {
      final itemValue = payload.item.value;

      switch (payload.event) {
        case TimedListEvent.added:
          _handleItemAdded(itemValue, DateTime.now());
          break;
        case TimedListEvent.removed:
          _handleItemRemoved(itemValue);
          break;
        case TimedListEvent.cleared:
          // We do nothing on 'cleared' to preserve history.
          break;
      }
    });
  }

  Future<void> _handleItemAdded(T item, DateTime addedAt) async {
    final docId = _idFromItem(item);
    final docRef = _collection.doc(docId);

    final payload = {
      'id': docId,
      'status': 'active',
      'addedAt': Timestamp.fromDate(addedAt),
      'lastSeenAt': Timestamp.now(),
      'endedAt': null,
    };

    print("🔥 (Backend) Firestore SET: doc('$docId') -> status: active");
    await docRef.set(payload, SetOptions(merge: true));
  }

  Future<void> _handleItemRemoved(T item) async {
    final docId = _idFromItem(item);
    final docRef = _collection.doc(docId);

    final payload = {
      'status': 'ended',
      'endedAt': Timestamp.now(),
    };

    print("🔥 (Backend) Firestore UPDATE: doc('$docId') -> status: ended");
    await docRef.update(payload);
  }

  void dispose() {
    _subscription?.cancel();
  }
}