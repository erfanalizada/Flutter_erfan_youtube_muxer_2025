import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  debugPrint('Running performance tests...');
  
  // Set longer timeout for performance tests
  const timeout = Timeout(Duration(minutes: 15));
  
  group('Performance Tests', () {
    setUp(() {
      // Set up test environment
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    testWidgets('Run all performance tests', (tester) async {
      await tester.runAsync(() async {
        main();
      });
    }, timeout: timeout);
  });
}
