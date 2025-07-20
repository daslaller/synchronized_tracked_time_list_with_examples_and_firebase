import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:synchronized_tracked_time_list/src/firestore_service.dart';
import 'package:synchronized_tracked_time_list/synchronized_tracked_time_list.dart';
import 'package:synchronized_tracked_time_list/src/realtime_example.dart';

Future<void> main() async {
  print("--- Full End-to-End Simulation with TimedList ---");

  // --- MOCK / SETUP ---
  final firestore = FirebaseFirestore.instance; // Requires a real project to run fully
  final phoneCollection = firestore.collection('my-tracked-numbers');

  // --- BACKEND SETUP ---
  print("\n[Setting up backend components...]");
  final contactList = SynchronizedTrackedTimeSet<String>();
  final syncService = FirestoreSyncService<String>(
    timedList: contactList,
    collection: phoneCollection,
    idFromItem: (phone) => phone.replaceAll(RegExp(r'[^0-9]'), ''),
  );

  // --- CLIENT SETUP ---
  print("[Setting up client listener...]\n");
  final clientDisplay = RealtimeStatusDisplay(collection: phoneCollection);
  
  // --- SIMULATION START ---
  print("--- Simulating poll results ---");
  
  // 1. First poll
  print("\n[Poll 1]");
  contactList.updateWith(['+111', '+222'], const Duration(seconds: 5));
  await Future.delayed(const Duration(seconds: 3));

  // 2. Second poll: '+222' disappears and is removed. '+333' is new.
  print("\n[Poll 2]");
  contactList.updateWith(['+111', '+333'], const Duration(seconds: 5));
  await Future.delayed(const Duration(seconds: 3));
  
  // At this point (6s elapsed), the timer for '+111' has fired, removing it.
  
  print("\n--- Simulation Complete ---");
  
  // --- CLEANUP ---
  syncService.dispose();
  clientDisplay.dispose();
  contactList.dispose();
}