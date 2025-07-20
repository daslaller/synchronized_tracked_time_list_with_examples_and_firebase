import 'package:synchronized_tracked_time_list/src/call.dart';

import 'package:synchronized_tracked_time_list/src/synchronized_tracked_set.dart';

void main() async {
  final timedSet = SynchronizedTimedSet(
    cleanupInterval: Duration(milliseconds: 0),
    maxBatchSize: 1,
  );

  // Listen to change events
  timedSet.events.listen((event) {
    print('EVENT: $event');
  });

  print('=== Initial synchronization with User data ===');
  timedSet.synchronize({
    Call(
      callerID: '1',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 500,
    ),
    Call(
      callerID: '2',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 650,
    ),
    Call(
      callerID: '3',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 650,
    ),
  });
  print(timedSet);

  await Future.delayed(Duration(milliseconds: 100));

  print('\n=== Modifying 1 data (age change) - should trigger MODIFIED ===');
  timedSet.synchronize({
    Call(
      callerID: '1',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.disconnected,
    ): Duration(
      milliseconds: 650,
    ), // Age changed
    Call(
      callerID: '2',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 599,
    ), // No change
    Call(
      callerID: '3',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 599,
    ), // New user
  });
  print(timedSet);

  await Future.delayed(Duration(milliseconds: 100));

  print(
    '\n=== Modifying CallID 1\'s tags and 2 - should trigger MODIFIED, and REMOVED for Callid 3 ===',
  );
  timedSet.synchronize({
    Call(
      callerID: '1',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 599,
    ), // No change
    Call(
      callerID: '2',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 599,
    ), // Tags changed
    Call(
      callerID: '5',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ): Duration(
      milliseconds: 599,
    ), // No change
  });
  print(timedSet);

  await Future.delayed(Duration(milliseconds: 200));

  print('\n=== After 200ms - some users should expire ===');
  print(timedSet);

  print(
    '\n=== Adding same user data (no changes) - should NOT trigger MODIFIED ===',
  );
  timedSet.synchronizeBatch([
    Call(
      callerID: '1',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ), // Exactly same
    Call(
      callerID: '2',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ), // New user
  ], Duration(milliseconds: 15000));
  print(timedSet);

  await Future.delayed(Duration(milliseconds: 300));
  print('\n=== After 300ms - checking final state ===');
  print(timedSet);
  print('Set size: ${timedSet.length}');
  print('initiating empty poll');
  timedSet.synchronize({});
  print(timedSet.isEmpty ? 'Successfull result' : 'Bad result');
  // Example with simple strings to show the difference
  print('\n\n=== Example with simple strings ===');
  final stringSet = SynchronizedTimedSet<String>();

  stringSet.events.listen((event) {
    print('STRING EVENT: $event');
  });

  stringSet.synchronizeBatch(['hello', 'world'], Duration(milliseconds: 300));
  await Future.delayed(Duration(milliseconds: 50));

  // Same strings - no modification events
  stringSet.synchronizeBatch(['hello', 'world'], Duration(milliseconds: 300));
  await Future.delayed(Duration(milliseconds: 50));

  // Different strings - should show modifications
  stringSet.synchronizeBatch([
    'hello',
    'universe',
  ], Duration(milliseconds: 300));

  Future.delayed(Duration(seconds: 10)).then((_) {
    print(timedSet.isEmpty ? 'Successfull result' : 'Bad result');
    print(stringSet.isEmpty ? 'Successfull result' : 'Bad result');
  });

  // Clean up
  timedSet.dispose();
  stringSet.dispose();
}
