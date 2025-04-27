import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionChecker {
  /// Checks if the app has the required storage permissions
  /// Returns true if all required permissions are granted, false otherwise
  static Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) { // Android 13 and above
        return await Permission.photos.isGranted && 
               await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted &&
             await Permission.mediaLibrary.isGranted;
    }
    return false;
  }

  /// Returns a list of required permissions that are not granted
  static Future<List<Permission>> getMissingPermissions() async {
    List<Permission> missingPermissions = [];

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        if (!await Permission.photos.isGranted) {
          missingPermissions.add(Permission.photos);
        }
        if (!await Permission.videos.isGranted) {
          missingPermissions.add(Permission.videos);
        }
      } else {
        if (!await Permission.storage.isGranted) {
          missingPermissions.add(Permission.storage);
        }
      }
    } else if (Platform.isIOS) {
      if (!await Permission.photos.isGranted) {
        missingPermissions.add(Permission.photos);
      }
      if (!await Permission.mediaLibrary.isGranted) {
        missingPermissions.add(Permission.mediaLibrary);
      }
    }

    return missingPermissions;
  }
}