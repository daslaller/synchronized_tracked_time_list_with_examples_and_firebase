import 'dart:async';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:synchronized_tracked_time_list/export_synchronized_tracked_set.dart'; // The file with SynchronizedTimedSet

class AppwriteSyncService<T> {
  final SynchronizedTimedSet<T> _timedSet;
  final Databases _database;
  final String _collectionId;
  final String Function(T item) _idProvider;
  final Map<String, dynamic> Function(T item) _serializer;
  StreamSubscription? _subscription;

  AppwriteSyncService({
    required SynchronizedTimedSet<T> timedSet,
    required Databases database,
    required String collectionId,
    required String Function(T item) idProvider,
    required Map<String, dynamic> Function(T item) serializer,
  }) : _timedSet = timedSet,
       _database = database,
       _collectionId = collectionId,
       _idProvider = idProvider,
       _serializer = serializer {
    _listenToChanges();
  }

  void _listenToChanges() {
    _subscription = _timedSet.events.listen((event) {
      final _ = switch (event.type) {
        ChangeType.added => _handleItemAdded(event.value, event.entry!),
        ChangeType.modified => _handleItemModified(event.value),
        ChangeType.removed => _handleItemRemovedOrExpired(
          event.value,
          'removed',
        ),
        ChangeType.expired => _handleItemRemovedOrExpired(
          event.value,
          'expired',
        ),
      };
    });
  }

  Future<void> _handleItemAdded(T item, TimedEntry<T> entry) async {
    final docId = _idProvider(item);
    final payload = {
      ..._serializer(item),
      'syncStatus': 'active',
      'addedAt': entry.addedAt
          .toIso8601String(), // Convert DateTime to string for Appwrite
      'expiresAt': entry.expiresAt
          .toIso8601String(), // Convert DateTime to string for Appwrite
      'lastModifiedAt': DateTime.now().toIso8601String(),
    };
    print("🚀 Appwrite CREATE: doc('$docId') -> status: active");
    await _database.createDocument(
      databaseId: '',
      collectionId: _collectionId,
      documentId: docId,
      data: payload,
    );
  }

  Future<void> _handleItemModified(T item) async {
    final docId = _idProvider(item);
    final payload = {
      ..._serializer(item),
      'lastModifiedAt': DateTime.now().toIso8601String(),
    };
    print("🚀 Appwrite UPDATE: doc('$docId') -> modified content");
    await _database.updateDocument(
      collectionId: _collectionId,
      documentId: docId,
      data: payload,
      databaseId: '',
    );
  }

  Future<void> _handleItemRemovedOrExpired(T item, String status) async {
    final docId = _idProvider(item);
    final payload = {
      'syncStatus': status, // 'removed' or 'expired'
      'endedAt': DateTime.now().toIso8601String(),
    };
    print("🚀 Appwrite UPDATE: doc('$docId') -> status: $status");
    await _database.updateDocument(
      collectionId: _collectionId,
      documentId: docId,
      data: payload,
      databaseId: '',
    );
  }

  void dispose() {
    _subscription?.cancel();
    print("AppwriteSyncService disposed.");
  }
}
