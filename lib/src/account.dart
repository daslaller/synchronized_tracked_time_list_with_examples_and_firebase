import 'dart:convert';
import 'dart:io';

class ServiceAccount {
  final String type,
      projectId,
      privateKeyId,
      privateKey,
      clientEmail,
      clientId,
      authUri,
      tokenUri,
      authProviderx509CertUrl,
      clientx509CertUrl,
      universeDomain;
  ServiceAccount({
    required this.type,
    required this.projectId,
    required this.privateKeyId,
    required this.privateKey,
    required this.clientEmail,
    required this.clientId,
    required this.authUri,
    required this.tokenUri,
    required this.authProviderx509CertUrl,
    required this.clientx509CertUrl,
    required this.universeDomain,
  });
  factory ServiceAccount.fromJsonFile({required File accountFile}) {
    if (!accountFile.existsSync()) {
      print(
        'Could not find service-account.json. Please download it from Firebase.',
      );
      exit(1);
    }
    final json = jsonDecode(accountFile.readAsStringSync());
    return ServiceAccount(
      type: json['type']??'',
      projectId: json['project_id']??'',
      privateKeyId: json['private_key_id']??'',
      privateKey: json['private_key']??'',
      clientEmail: json['client_email']??'',
      clientId: json['client_id']??'',
      authUri: json['auth_uri']??'',
      tokenUri: json['token_uri']??'',
      authProviderx509CertUrl: json['auth_provider_x509_cert_url']??'',
      clientx509CertUrl: json['client_x509_cert_url']??'',
      universeDomain: json['universe_domain']??'',
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
}
