import 'dart:async';
import 'dart:developer';
import 'package:uuid/v8.dart';

enum TimedListEvent { added, removed, cleared }

/// The event payload containing the event type and the affected item.
class TimedListPayload<T> {
  final TimedListEvent event;
  final TimedItem<T> item;
  TimedListPayload(this.event, this.item);
}

class TimedItem<T> {
  final T value;
  final Duration lifetime;
  final List<Function> onExpired;
  late final Timer _timer;
  final String identifier;

  TimedItem(this.value, this.lifetime, {List<Function>? initialCallbacks})
      : identifier = const UuidV8().generate(),
        onExpired = initialCallbacks ?? [] {
    _timer = Timer(lifetime, () {
      for (var function in onExpired) {
        function();
      }
    });
  }

  void cancel() {
    _timer.cancel();
  }
}

/// A list that automatically removes items after a specified lifetime
/// and can be synchronized with an external dataset.
class SynchronizedTrackedTimeSet<T> {
  final List<TimedItem<T>> _elementList = [];
  final StreamController<TimedListPayload<T>> _eventsController =
      StreamController.broadcast();
  Stream<TimedListPayload<T>> get events => _eventsController.stream;

  /// Adds an item to the list with a specified lifetime.
  void add(T value, Duration lifetime) {
    if (contains(value)) return;

    final item = TimedItem<T>(value, lifetime);
    item.onExpired.add(() => _removeItem(item));
    _elementList.add(item);
    _eventsController.add(TimedListPayload(TimedListEvent.added, item));
    log('id: ${item.identifier} (${item.value}) has been added');
  }

  /// Removes an item from the list based on its value.
  void removeValue(T value) {
    // Find the item by value.
    final itemToRemove = _elementList.firstWhere((item) => item.value == value,
        orElse: () => TimedItem<T>(value, Duration.zero)); // Dummy item if not found

    if (_elementList.any((item) => item.value == value)) {
       _removeItem(itemToRemove);
    }
  }

  /// The internal removal logic, triggered by timer or manual removal.
  void _removeItem(TimedItem<T> element) {
    log('remove item ${element.identifier} (${element.value}) has been requested');
    element.cancel();

    final initialCount = _elementList.length;
    _elementList.removeWhere((item) => item.identifier == element.identifier);
    final removed = _elementList.length < initialCount;

    if (removed) {
      _eventsController.add(TimedListPayload(TimedListEvent.removed, element));
      log('item with id: ${element.identifier} has been removed');
    }
  }

  /// Synchronizes the list with a new dataset from a poll.
  void updateWith(Iterable<T> newValues, Duration lifetime) {
    final newSet = newValues.toSet();
    final currentSet = _elementList.map((item) => item.value).toSet();

    final toRemove = currentSet.difference(newSet);
    for (final value in toRemove) {
      removeValue(value);
    }

    final toAdd = newSet.difference(currentSet);
    for (final value in toAdd) {
      add(value, lifetime);
    }

    log('Update complete. Added: ${toAdd.length}, Removed: ${toRemove.length}.');
  }

  bool contains(T value) {
    return _elementList.any((item) => item.value == value);
  }

  void clear() {
    for (var item in _elementList) {
      item.cancel();
    }
    _elementList.clear();
    log('TimedList has been cleared.');
  }

  int get length => _elementList.length;

  void dispose() {
    clear();
    _eventsController.close();
  }
}