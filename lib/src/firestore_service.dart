import 'dart:async';
import 'package:firedart/firedart.dart';
import 'package:synchronized_tracked_time_list/export_synchronized_tracked_set.dart';

class FiredartSyncService<T> {
  final SynchronizedTimedSet<T> _timedSet;
  final CollectionReference _collection;
  final String Function(T item) _idProvider;
  final Map<String, dynamic> Function(T item) _serializer;
  StreamSubscription? _subscription;

  FiredartSyncService({
    required SynchronizedTimedSet<T> timedSet,
    required CollectionReference collection,
    required String Function(T item) idProvider,
    required Map<String, dynamic> Function(T item) serializer,
  })  : _timedSet = timedSet,
        _collection = collection,
        _idProvider = idProvider,
        _serializer = serializer {
    _listenToChanges();
  }

  void _listenToChanges() {
    _subscription = _timedSet.events.listen((event) {
      switch (event.type) {
        case ChangeType.added:
          _handleItemAdded(event.value, event.entry!);
          break;
        case ChangeType.modified:
          _handleItemModified(event.value);
          break;
        case ChangeType.removed:
          _handleItemRemovedOrExpired(event.value, 'removed');
          break;
        case ChangeType.expired:
          _handleItemRemovedOrExpired(event.value, 'expired');
          break;
      }
    });
  }

  Future<void> _handleItemAdded(T item, TimedEntry<T> entry) async {
    final docId = _idProvider(item);
    final payload = {
      ..._serializer(item),
      'syncStatus': 'active',
      'addedAt': entry.addedAt.toIso8601String(),
      'expiresAt': entry.expiresAt.toIso8601String(),
      'lastModifiedAt': DateTime.now().toIso8601String(),
    };
    print("🔥 Firedart SET: doc('$docId') -> status: active");
    await _collection.document(docId).set(payload);
  }

  Future<void> _handleItemModified(T item) async {
    final docId = _idProvider(item);
    final payload = {
      ..._serializer(item),
      'lastModifiedAt': DateTime.now().toIso8601String(),
    };
    print("🔥 Firedart UPDATE: doc('$docId') -> modified content");
    await _collection.document(docId).update(payload);
  }

  Future<void> _handleItemRemovedOrExpired(T item, String status) async {
    final docId = _idProvider(item);
    final payload = {
      'syncStatus': status, // 'removed' or 'expired'
      'endedAt': DateTime.now().toIso8601String(),
    };
    print("🔥 Firedart UPDATE: doc('$docId') -> status: $status");
    await _collection.document(docId).update(payload);
  }

  void dispose() {
    _subscription?.cancel();
    print("FiredartSyncService disposed.");
  }
}