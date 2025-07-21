import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core_dart/firebase_core_dart.dart';
import 'package:synchronized_tracked_time_list/export_synchronized_tracked_set.dart';
import 'package:synchronized_tracked_time_list/src/account.dart';
import 'package:synchronized_tracked_time_list/src/call.dart';
import 'package:synchronized_tracked_time_list/src/firestore_service.dart';

Future<void> main() async {
  // --- FIREBASE INITIALIZATION ---
  // Initialize the app using the generated options file.

  final serviceAccount = ServiceAccount.fromFile(
    accountFile: File(
      'example/mgr-telavox-server-firebase-adminsdk-fbsvc-d14433a337.json',
    ),
  );
  serviceAccount.initFire();
  final firestore = FirebaseFirestore.instance;
  print("🔥 Firebase SDK Initialized");

  // --- APPLICATION SETUP ---
  final callSet = SynchronizedTimedSet<Call>(
    cleanupInterval: Duration(milliseconds: 100),
  );

  final callCollection = firestore.collection('telavox_calls_client');

  final syncService = FirebaseSyncService<Call>(
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
    ): Duration(
      seconds: 5,
    ),
  });

  await Future.delayed(const Duration(seconds: 2));

  print('\n=== Poll 2: Call is answered (status modification) ===');
  callSet.synchronize({
    Call(
      callerID: '+46701234567',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected, // Status changed!
    ): Duration(
      seconds: 5,
    ),
  });

  await Future.delayed(const Duration(seconds: 4));
  print('\n=== After delay, the first call should have expired ===');

  await Future.delayed(const Duration(seconds: 2));

  // --- CLEANUP ---
  callSet.dispose();
  syncService.dispose();
  print('\n=== Simulation Complete ===');
}
