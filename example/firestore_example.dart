import 'dart:io';
import 'package:firebase_core_dart/firebase_core_dart.dart';
import 'package:synchronized_tracked_time_list/export_synchronized_tracked_set.dart';
import 'package:synchronized_tracked_time_list/src/account.dart';
import 'package:synchronized_tracked_time_list/src/call.dart';
import 'package:synchronized_tracked_time_list/src/firestore_service.dart';

Future<void> main() async {

  // --- APPLICATION SETUP ---
  final callSet = SynchronizedTimedSet<Call>(
    cleanupInterval: Duration(milliseconds: 100)
  );
 
  final callCollection = Firebase.collection('telavox_calls_admin');
  
  final syncService = FiredartSyncService<Call>(

    timedSet: callSet,
    collection: callCollection,
    idProvider: (call) => call.uniqueIdentfier,
    serializer: (call) => call.toJson(),
  );
  
  callSet.events.listen((event) {
    print('LOCAL EVENT: $event');
  });
  
  // --- SIMULATION ---
  print('\n=== Poll 1: New incoming call ===');
  callSet.synchronize({
    Call(
      callerID: '+46701234567',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.ringing,
    ): Duration(seconds: 10),
  });
  
  await Future.delayed(const Duration(seconds: 2));
  
  print('\n=== Poll 2: Call is answered (status modification) ===');
  callSet.synchronize({
    Call(
      callerID: '+46701234567',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected, // Status changed!
    ): Duration(seconds: 10),
  });
  
  await Future.delayed(const Duration(seconds: 2));

  // --- CLEANUP ---
  callSet.dispose();
  syncService.dispose();
  print('\n=== Simulation Complete ===');
}