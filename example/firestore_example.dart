import 'dart:io';

import 'package:firedart/auth/firebase_auth.dart';
import 'package:firedart/firedart.dart';
import 'package:synchronized_tracked_time_list/export_synchronized_tracked_set.dart';
import 'package:synchronized_tracked_time_list/src/account.dart' as account;
import 'package:synchronized_tracked_time_list/src/call.dart';
import 'package:synchronized_tracked_time_list/src/firestore_service.dart';

/// Initialize Firebase with service account authentication
Future<void> initializeFirebase() async {
  // Load service account from JSON file
  final serviceAccountFile = File('example/mgr-telavox-server-firebase-adminsdk-fbsvc-d14433a337.json');

  if (!serviceAccountFile.existsSync()) {
    throw Exception(
      'service-account.json not found. Please download it from Firebase Console:\n'
      '1. Go to Firebase Console > Project Settings > Service Accounts\n'
      '2. Click "Generate new private key"\n'
      '3. Save the file as "service-account.json" in the project root',
    );
  }

  final serviceAccount = account.ServiceAccount.fromJsonFile(
    accountFile: serviceAccountFile,
  );

  // Initialize Firedart
  if (!Firestore.initialized) {
    Firestore.initialize(serviceAccount.projectId);
  }

  // For this example, we'll use anonymous authentication
  // In production, implement proper service account authentication
  await FirebaseAuth.initialize(serviceAccount.projectId, VolatileStore());

  // Sign in anonymously for this example
  await FirebaseAuth.instance.signInAnonymously();

  print('✅ Firebase initialized and authenticated successfully');
  print('🏢 Project ID: ${serviceAccount.projectId}');
  print(
    '⚠️  Note: Using anonymous auth for demo. In production, use service account auth.',
  );
}

// Your custom set already handles the identity key for Call.
// No extension is needed if you keep the logic inside the base class.

Future<void> main() async {
  // --- FIREDART INITIALIZATION ---
  initializeFirebase();
  // --- APPLICATION SETUP ---
  // Using the base class directly as it already knows how to handle Call identity.
  final callSet = SynchronizedTimedSet<Call>(
    cleanupInterval: Duration(milliseconds: 100),
  );

  final callCollection = Firestore.instance.collection('telavox_calls');

  // Wire up the service with the correct providers for your Call model
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
    ): Duration(
      seconds: 10,
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
      seconds: 10,
    ),
    Call(
      callerID: '+46707654321', // New call appears
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.ringing,
    ): Duration(
      seconds: 5,
    ),
  });

  await Future.delayed(const Duration(seconds: 3));

  print('\n=== Poll 3: First call disappears, second is still connected ===');
  callSet.synchronize({
    Call(
      // Only this call remains in the poll
      callerID: '+46707654321',
      direction: TelavoxDirection.incoming,
      status: TelavoxLineStatus.connected,
    ): Duration(
      seconds: 5,
    ),
  });

  await Future.delayed(const Duration(seconds: 3));
  print('\n=== After delay, the second call should expire ===');

  await Future.delayed(const Duration(seconds: 3));

  // --- CLEANUP ---
  callSet.dispose();
  syncService.dispose();
  print('\n=== Simulation Complete ===');
}
