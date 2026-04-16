// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'gecko.g.dart';

/// Class constants for [GeckoSessionPermissionDelegateCallback].
///
/// Since the Dart [GeckoSessionPermissionDelegateCallback] is generated, the constants for the class
/// are added here.
class PermissionRequestConstants {
  static const String camera = 'android.permission.CAMERA';
  static const String recordAudio = 'android.permission.RECORD_AUDIO';
}

class StorageControllerClearFlags {
  static const int cookies = 1;
  static const int networkCache = 2;
  static const int imageCache = 4;
  static const int domStorages = 16;
  static const int authSessions = 32;
  static const int permissions = 64;
  static const int allCaches = 6;
  static const int siteSettings = 192;
  static const int siteData = 471;
  static const int all = 512;
}
