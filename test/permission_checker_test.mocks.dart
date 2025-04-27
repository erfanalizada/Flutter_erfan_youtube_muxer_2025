import 'dart:async' as i10;

import 'package:device_info_plus/device_info_plus.dart' as i9;
import 'package:device_info_plus/src/model/android_device_info.dart' as i2;
import 'package:device_info_plus/src/model/ios_device_info.dart' as i3;
import 'package:device_info_plus/src/model/linux_device_info.dart' as i4;
import 'package:device_info_plus/src/model/macos_device_info.dart' as i6;
import 'package:device_info_plus/src/model/web_browser_info.dart' as i5;
import 'package:device_info_plus/src/model/windows_device_info.dart' as i7;
import 'package:device_info_plus_platform_interface/device_info_plus_platform_interface.dart'
    as i8;
import 'package:mockito/mockito.dart' as i1;
import 'package:mockito/src/dummies.dart' as i11;

class FakeAndroidDeviceInfo extends i1.SmartFake
    implements i2.AndroidDeviceInfo {
  FakeAndroidDeviceInfo(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeIosDeviceInfo extends i1.SmartFake implements i3.IosDeviceInfo {
  FakeIosDeviceInfo(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeLinuxDeviceInfo extends i1.SmartFake
    implements i4.LinuxDeviceInfo {
  FakeLinuxDeviceInfo(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeWebBrowserInfo extends i1.SmartFake
    implements i5.WebBrowserInfo {
  FakeWebBrowserInfo(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeMacOsDeviceInfo extends i1.SmartFake
    implements i6.MacOsDeviceInfo {
  FakeMacOsDeviceInfo(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeWindowsDeviceInfo extends i1.SmartFake
    implements i7.WindowsDeviceInfo {
  FakeWindowsDeviceInfo(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeBaseDeviceInfo extends i1.SmartFake
    implements i8.BaseDeviceInfo {
  FakeBaseDeviceInfo(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeAndroidBuildVersion extends i1.SmartFake
    implements i2.AndroidBuildVersion {
  FakeAndroidBuildVersion(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class FakeIosUtsname extends i1.SmartFake implements i3.IosUtsname {
  FakeIosUtsname(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [DeviceInfoPlugin].
///
/// See the documentation for Mockito's code generation for more information.
class MockDeviceInfoPlugin extends i1.Mock implements i9.DeviceInfoPlugin {
  MockDeviceInfoPlugin() {
    i1.throwOnMissingStub(this);
  }

  @override
  i10.Future<i2.AndroidDeviceInfo> get androidInfo => (super.noSuchMethod(
        Invocation.getter(#androidInfo),
        returnValue:
            i10.Future<i2.AndroidDeviceInfo>.value(FakeAndroidDeviceInfo(
          this,
          Invocation.getter(#androidInfo),
        )),
      ) as i10.Future<i2.AndroidDeviceInfo>);

  @override
  i10.Future<i3.IosDeviceInfo> get iosInfo => (super.noSuchMethod(
        Invocation.getter(#iosInfo),
        returnValue: i10.Future<i3.IosDeviceInfo>.value(FakeIosDeviceInfo(
          this,
          Invocation.getter(#iosInfo),
        )),
      ) as i10.Future<i3.IosDeviceInfo>);

  @override
  i10.Future<i4.LinuxDeviceInfo> get linuxInfo => (super.noSuchMethod(
        Invocation.getter(#linuxInfo),
        returnValue:
            i10.Future<i4.LinuxDeviceInfo>.value(FakeLinuxDeviceInfo(
          this,
          Invocation.getter(#linuxInfo),
        )),
      ) as i10.Future<i4.LinuxDeviceInfo>);

  @override
  i10.Future<i5.WebBrowserInfo> get webBrowserInfo => (super.noSuchMethod(
        Invocation.getter(#webBrowserInfo),
        returnValue:
            i10.Future<i5.WebBrowserInfo>.value(FakeWebBrowserInfo(
          this,
          Invocation.getter(#webBrowserInfo),
        )),
      ) as i10.Future<i5.WebBrowserInfo>);

  @override
  i10.Future<i6.MacOsDeviceInfo> get macOsInfo => (super.noSuchMethod(
        Invocation.getter(#macOsInfo),
        returnValue:
            i10.Future<i6.MacOsDeviceInfo>.value(FakeMacOsDeviceInfo(
          this,
          Invocation.getter(#macOsInfo),
        )),
      ) as i10.Future<i6.MacOsDeviceInfo>);

  @override
  i10.Future<i7.WindowsDeviceInfo> get windowsInfo => (super.noSuchMethod(
        Invocation.getter(#windowsInfo),
        returnValue:
            i10.Future<i7.WindowsDeviceInfo>.value(FakeWindowsDeviceInfo(
          this,
          Invocation.getter(#windowsInfo),
        )),
      ) as i10.Future<i7.WindowsDeviceInfo>);

  @override
  i10.Future<i8.BaseDeviceInfo> get deviceInfo => (super.noSuchMethod(
        Invocation.getter(#deviceInfo),
        returnValue:
            i10.Future<i8.BaseDeviceInfo>.value(FakeBaseDeviceInfo(
          this,
          Invocation.getter(#deviceInfo),
        )),
      ) as i10.Future<i8.BaseDeviceInfo>);
}

/// A class which mocks [AndroidDeviceInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockAndroidDeviceInfo extends i1.Mock implements i2.AndroidDeviceInfo {
  MockAndroidDeviceInfo() {
    i1.throwOnMissingStub(this);
  }

  @override
  i2.AndroidBuildVersion get version => (super.noSuchMethod(
        Invocation.getter(#version),
        returnValue: FakeAndroidBuildVersion(
          this,
          Invocation.getter(#version),
        ),
      ) as i2.AndroidBuildVersion);

  @override
  String get board => (super.noSuchMethod(
        Invocation.getter(#board),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#board),
        ),
      ) as String);

  @override
  String get bootloader => (super.noSuchMethod(
        Invocation.getter(#bootloader),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#bootloader),
        ),
      ) as String);

  @override
  String get brand => (super.noSuchMethod(
        Invocation.getter(#brand),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#brand),
        ),
      ) as String);

  @override
  String get device => (super.noSuchMethod(
        Invocation.getter(#device),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#device),
        ),
      ) as String);

  @override
  String get display => (super.noSuchMethod(
        Invocation.getter(#display),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#display),
        ),
      ) as String);

  @override
  String get fingerprint => (super.noSuchMethod(
        Invocation.getter(#fingerprint),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#fingerprint),
        ),
      ) as String);

  @override
  String get hardware => (super.noSuchMethod(
        Invocation.getter(#hardware),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#hardware),
        ),
      ) as String);

  @override
  String get host => (super.noSuchMethod(
        Invocation.getter(#host),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#host),
        ),
      ) as String);

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  String get manufacturer => (super.noSuchMethod(
        Invocation.getter(#manufacturer),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#manufacturer),
        ),
      ) as String);

  @override
  String get model => (super.noSuchMethod(
        Invocation.getter(#model),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#model),
        ),
      ) as String);

  @override
  String get product => (super.noSuchMethod(
        Invocation.getter(#product),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#product),
        ),
      ) as String);

  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#name),
        ),
      ) as String);

  @override
  List<String> get supported32BitAbis => (super.noSuchMethod(
        Invocation.getter(#supported32BitAbis),
        returnValue: <String>[],
      ) as List<String>);

  @override
  List<String> get supported64BitAbis => (super.noSuchMethod(
        Invocation.getter(#supported64BitAbis),
        returnValue: <String>[],
      ) as List<String>);

  @override
  List<String> get supportedAbis => (super.noSuchMethod(
        Invocation.getter(#supportedAbis),
        returnValue: <String>[],
      ) as List<String>);

  @override
  String get tags => (super.noSuchMethod(
        Invocation.getter(#tags),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#tags),
        ),
      ) as String);

  @override
  String get type => (super.noSuchMethod(
        Invocation.getter(#type),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#type),
        ),
      ) as String);

  @override
  bool get isPhysicalDevice => (super.noSuchMethod(
        Invocation.getter(#isPhysicalDevice),
        returnValue: false,
      ) as bool);

  @override
  List<String> get systemFeatures => (super.noSuchMethod(
        Invocation.getter(#systemFeatures),
        returnValue: <String>[],
      ) as List<String>);

  @override
  String get serialNumber => (super.noSuchMethod(
        Invocation.getter(#serialNumber),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#serialNumber),
        ),
      ) as String);

  @override
  bool get isLowRamDevice => (super.noSuchMethod(
        Invocation.getter(#isLowRamDevice),
        returnValue: false,
      ) as bool);

  @override
  int get physicalRamSize => (super.noSuchMethod(
        Invocation.getter(#physicalRamSize),
        returnValue: 0,
      ) as int);

  @override
  int get availableRamSize => (super.noSuchMethod(
        Invocation.getter(#availableRamSize),
        returnValue: 0,
      ) as int);

  @override
  Map<String, dynamic> get data => (super.noSuchMethod(
        Invocation.getter(#data),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  Map<String, dynamic> toMap() => (super.noSuchMethod(
        Invocation.method(
          #toMap,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}

/// A class which mocks [IosDeviceInfo].
///
/// See the documentation for Mockito's code generation for more information.
class MockIosDeviceInfo extends i1.Mock implements i3.IosDeviceInfo {
  MockIosDeviceInfo() {
    i1.throwOnMissingStub(this);
  }

  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#name),
        ),
      ) as String);

  @override
  String get systemName => (super.noSuchMethod(
        Invocation.getter(#systemName),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#systemName),
        ),
      ) as String);

  @override
  String get systemVersion => (super.noSuchMethod(
        Invocation.getter(#systemVersion),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#systemVersion),
        ),
      ) as String);

  @override
  String get model => (super.noSuchMethod(
        Invocation.getter(#model),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#model),
        ),
      ) as String);

  @override
  String get modelName => (super.noSuchMethod(
        Invocation.getter(#modelName),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#modelName),
        ),
      ) as String);

  @override
  String get localizedModel => (super.noSuchMethod(
        Invocation.getter(#localizedModel),
        returnValue: i11.dummyValue<String>(
          this,
          Invocation.getter(#localizedModel),
        ),
      ) as String);

  @override
  bool get isPhysicalDevice => (super.noSuchMethod(
        Invocation.getter(#isPhysicalDevice),
        returnValue: false,
      ) as bool);

  @override
  int get physicalRamSize => (super.noSuchMethod(
        Invocation.getter(#physicalRamSize),
        returnValue: 0,
      ) as int);

  @override
  int get availableRamSize => (super.noSuchMethod(
        Invocation.getter(#availableRamSize),
        returnValue: 0,
      ) as int);

  @override
  bool get isiOSAppOnMac => (super.noSuchMethod(
        Invocation.getter(#isiOSAppOnMac),
        returnValue: false,
      ) as bool);

  @override
  i3.IosUtsname get utsname => (super.noSuchMethod(
        Invocation.getter(#utsname),
        returnValue: FakeIosUtsname(
          this,
          Invocation.getter(#utsname),
        ),
      ) as i3.IosUtsname);

  @override
  Map<String, dynamic> get data => (super.noSuchMethod(
        Invocation.getter(#data),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);

  @override
  Map<String, dynamic> toMap() => (super.noSuchMethod(
        Invocation.method(
          #toMap,
          [],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}






