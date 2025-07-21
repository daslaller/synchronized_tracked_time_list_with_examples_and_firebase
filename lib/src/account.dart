import 'dart:convert';
import 'dart:io';

import 'package:firebase_core_dart/firebase_core_dart.dart';

class ServiceAccount {
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
  ServiceAccount({
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
  factory ServiceAccount.fromFile({required File accountFile}) {
    if (!accountFile.existsSync()) {
      print(
        'Could not find service-account.json. Please download it from Firebase.',
      );
      exit(1);
    }
    final json = jsonDecode(accountFile.readAsStringSync());
    return ServiceAccount(
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
