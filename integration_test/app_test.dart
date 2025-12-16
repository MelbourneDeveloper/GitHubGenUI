// Integration test entry point.
// Run with: flutter test integration_test/
//
// These are the SAME tests as in test/full_app_test.dart but run on device.
// See: https://www.christianfindlay.com/blog/flutter-integration-tests

import 'package:integration_test/integration_test.dart';

import '../test/full_app_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Run all the same tests from full_app_test.dart
  runFullAppTests();
}
