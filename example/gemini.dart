import 'package:synchronized_tracked_time_list/src/call.dart';
import 'package:synchronized_tracked_time_list/synchronized_tracked_time_list.dart';

Future<void> main() async {
   final timedSet = SynchronizedTrackedTimeSet<Call>();
   timedSet.events.listen((onData){
    print('Event: ${onData.event} for ${onData.item.value}');
   });
 print('=== Initial synchronization with User data ===');
  timedSet.updateWith([
    Call(
      callerID: '1',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    
    ),
    Call(
      callerID: '2',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    
    ),
    Call(
      callerID: '3',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    
    ),
  ], Duration(milliseconds: 500));
  print(timedSet);
  
  await Future.delayed(Duration(milliseconds: 100));
  
  print('\n=== Modifying Alice\'s data (age change) - should trigger MODIFIED ===');
  timedSet.updateWith([
    Call(
      callerID: '1',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.disconnected,
    ), // Age changed
    Call(
      callerID: '2',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ), // No change
    Call(
      callerID: '3',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ),        // New user
  ], Duration(milliseconds: 400));
  print(timedSet);
  
  await Future.delayed(Duration(milliseconds: 100));
  
  print('\n=== Modifying Bob\'s tags - should trigger MODIFIED ===');
  timedSet.updateWith([
    Call(
      callerID: '1',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ), // No change
    Call(
      callerID: '2',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ), // Tags changed
    Call(
      callerID: '5',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ),         // No change
  ], Duration(milliseconds: 400));
  print(timedSet);
  
  await Future.delayed(Duration(milliseconds: 200));
  
  print('\n=== After 200ms - some users should expire ===');
  print(timedSet);
  
  print('\n=== Adding same user data (no changes) - should NOT trigger MODIFIED ===');
  timedSet.updateWith([
    Call(
      callerID: '1',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ), // Exactly same
    Call(
      callerID: '2',
      direction: TelavoxDirection.outgoing,
      status: TelavoxLineStatus.connected,
    ), // New user       // New user
  ], Duration(milliseconds: 500));
  print(timedSet);
  
  await Future.delayed(Duration(milliseconds: 300));
  print('\n=== After 300ms - checking final state ===');
  print(timedSet);
  
  // Example with simple strings to show the difference
  print('\n\n=== Example with simple strings ===');
  final stringSet = SynchronizedTrackedTimeSet<String>();
  
  stringSet.events.listen((event) {
    print('STRING EVENT: ${event.event} for ${event.item.value}');
  });
  
  stringSet.updateWith(['hello', 'world'], Duration(milliseconds: 300));
  await Future.delayed(Duration(milliseconds: 50));
  
  // Same strings - no modification events
  stringSet.updateWith(['hello', 'world'], Duration(milliseconds: 300));
  await Future.delayed(Duration(milliseconds: 50));
  
  // Different strings - should show modifications
  stringSet.updateWith(['hello', 'universe'], Duration(milliseconds: 300));
  
  // Clean up
  timedSet.dispose();
  stringSet.dispose();
}