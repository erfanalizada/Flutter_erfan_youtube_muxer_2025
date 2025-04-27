import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_erfan_youtube_muxer_2025/src/permission_checker.dart';
import 'permission_checker_test.mocks.dart';

@GenerateMocks([
  DeviceInfoPlugin,
  AndroidDeviceInfo,
  IosDeviceInfo
])
class MockAndroidBuildVersion extends Mock implements AndroidBuildVersion {}

void main() {
  group('PermissionChecker Tests', () {
    late MockDeviceInfoPlugin mockDeviceInfo;
    late MockAndroidDeviceInfo mockAndroidInfo;
    late MockAndroidBuildVersion mockAndroidBuildVersion;

    setUp(() {
      mockDeviceInfo = MockDeviceInfoPlugin();
      mockAndroidInfo = MockAndroidDeviceInfo();
      mockAndroidBuildVersion = MockAndroidBuildVersion();
      
      // Set up default mock responses
      when(mockDeviceInfo.androidInfo).thenAnswer((_) async => mockAndroidInfo);
      when(mockAndroidInfo.version).thenReturn(mockAndroidBuildVersion);
    });

    test('Android 13+ permissions check returns true when all permissions granted', () async {
      when(mockAndroidBuildVersion.sdkInt).thenReturn(33);
      
      // Mock permission handler responses
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_permission_handler'), 
          (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return Permission.photos.value;
        }
        return null;
      });
      
      final result = await PermissionChecker.hasStoragePermission();
      expect(result, true);
    });

    test('Android 12 and below permissions check returns true when storage permission granted', () async {
      when(mockAndroidBuildVersion.sdkInt).thenReturn(31);
      
      // Mock permission handler responses
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_permission_handler'), 
          (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return Permission.storage.value;
        }
        return null;
      });
      
      final result = await PermissionChecker.hasStoragePermission();
      expect(result, true);
    });

    test('getMissingPermissions returns empty list when all permissions granted', () async {
      when(mockAndroidBuildVersion.sdkInt).thenReturn(33);
      
      // Mock permission handler responses
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('flutter_permission_handler'), 
          (MethodCall methodCall) async {
        if (methodCall.method == 'checkPermissionStatus') {
          return PermissionStatus.granted.index;
        }
        return null;
      });
      
      final result = await PermissionChecker.getMissingPermissions();
      expect(result, isEmpty);
    });
  });
}



