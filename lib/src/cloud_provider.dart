// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:firebase_core_dart/firebase_core_dart.dart';

class FirebaseFirestoreProvider {
  FirebaseOptions get _options => FirebaseOptions.fromMap(toJson());

  final String type;
  final String projectId;
  final String privateKeyId;
  final String privateKey;
  final String clientEmail;
  final String clientId;
  final String authUri;
  final String tokenUri;
  final String authProviderx509CertUrl;
  final String clientx509CertUrl;
  final String universeDomain;
  FirebaseFirestoreProvider({
    this.type = '',
    this.projectId = '',
    this.privateKeyId = '',
    this.privateKey = '',
    this.clientEmail = '',
    this.clientId = '',
    this.authUri = '',
    this.tokenUri = '',
    this.authProviderx509CertUrl = '',
    this.clientx509CertUrl = '',
    this.universeDomain = '',
  });
  factory FirebaseFirestoreProvider.fromFile({required File accountFile}) {
    if (!accountFile.existsSync()) {
      print(
        'Could not find service-account.json. Please download it from Firebase.',
      );
      exit(1);
    }
    final json = jsonDecode(accountFile.readAsStringSync());
    return FirebaseFirestoreProvider(
      type: json['type'] ?? '',
      projectId: json['project_id'] ?? '',
      privateKeyId: json['private_key_id'] ?? '',
      privateKey: json['private_key'] ?? '',
      clientEmail: json['client_email'] ?? '',
      clientId: json['client_id'] ?? '',
      authUri: json['auth_uri'] ?? '',
      tokenUri: json['token_uri'] ?? '',
      authProviderx509CertUrl: json['auth_provider_x509_cert_url'] ?? '',
      clientx509CertUrl: json['client_x509_cert_url'] ?? '',
      universeDomain: json['universe_domain'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'project_id': projectId,
      'private_key_id': privateKeyId,
      'private_key': privateKey,
      'client_email': clientEmail,
      'client_id': clientId,
      'auth_uri': authUri,
      'token_uri': tokenUri,
      'auth_provider_x509_cert_url': authProviderx509CertUrl,
      'client_x509_cert_url': clientx509CertUrl,
      'universe_domain': universeDomain,
    };
  }

  Future<FirebaseApp> initiateFirestore() async =>
      await Firebase.initializeApp(options: _options);
}

enum CloudProvider { firebase, appwrite, supabase }

enum _RegionCodes { FRA, NYC, SYD, SGP, SFO, BLR, AMS, LON, TOR, MUM }

enum AppWriteRegions {
  Frankfurt(
    regionCode: _RegionCodes.FRA,
    endpoint: 'https://fra.cloud.appwrite.io/v1',
    availability: true,
  ),
  New_York(
    regionCode: _RegionCodes.NYC,
    endpoint: 'https://nyc.cloud.appwrite.io/v1',
    availability: true,
  ),
  Sydney(
    regionCode: _RegionCodes.SYD,
    endpoint: 'https://syd.cloud.appwrite.io/v1',
    availability: true,
  ),
  Singapore(
    regionCode: _RegionCodes.SGP,
    endpoint: 'coming soon',
    availability: 'Q4_2025',
  ),
  San_Francisco(
    regionCode: _RegionCodes.SFO,
    endpoint: 'coming soon',
    availability: 'Q4_2025',
  ),
  Bangalore(
    regionCode: _RegionCodes.BLR,
    endpoint: 'coming soon',
    availability: 'TBD',
  ),
  Amsterdam(
    regionCode: _RegionCodes.AMS,
    endpoint: 'coming soon',
    availability: 'TBD',
  ),
  London(
    regionCode: _RegionCodes.LON,
    endpoint: 'coming soon',
    availability: 'TBD',
  ),
  Toronto(
    regionCode: _RegionCodes.TOR,
    endpoint: 'coming soon',
    availability: 'TBD',
  ),
  Mumbai(
    regionCode: _RegionCodes.MUM,
    endpoint: 'coming soon',
    availability: 'TBD',
  );

  final _RegionCodes regionCode;
  final String endpoint;
  final dynamic availability;
  const AppWriteRegions({
    required this.regionCode,
    required this.endpoint,
    required this.availability,
  });
}

class AppWriteProvider {
  final Client _client = Client();
  final AppWriteRegions region;
  final String projectId, key;

  Databases? _databases;

  static AppWriteProvider? get instance => _instance;
  Databases get db => _databases ?? Databases(_client);
  Client get client => _client;
  Future<bool> get connected async => await _client.ping().then((value) {
    print('Ping response: $value');
    return value.endsWith('Pong!');
  });
  // ignore: unused_field
  static AppWriteProvider? _instance;
  AppWriteProvider._({
    required this.region,
    required this.projectId,
    required this.key,
  }) {
    if (region.availability is String) {
      String availability = region.availability as String;
      throw Exception(
        'Region ${region.regionCode} is not available, ${availability.endsWith('TBC') ? 'coming soon' : 'implementation should be done $availability'}',
      );
    }

    _client
        .setEndpoint(region.endpoint) // Your API Endpoint
        .setProject(projectId) // Your project ID
        .setKey(key); // Your secret API key
    _databases ??= Databases(_client);
  }
  factory AppWriteProvider({
    required AppWriteRegions region,
    required String projectId,
    required String key,
  }) => _instance ??= AppWriteProvider._(
    region: region,
    projectId: projectId,
    key: key,
  );
}

class SupabaseProvider {
  SupabaseProvider() {
    throw Exception('SupabaseProvider not implemented');
  }
}
