import 'dart:convert';
import 'dart:io';

class ServiceAccount {
  final String projectId;
  final String apiKey;
  final String? email;
  final String? password;
  ServiceAccount({
    required this.projectId,
    required this.apiKey,
    this.email = '',
    this.password = '',
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
      projectId: json['projectId'],
      apiKey: json['apiKey'],
      email: json['email'],
      password: json['password'],
    );
  }
}
