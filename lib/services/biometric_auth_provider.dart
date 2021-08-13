import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class LocalAuthProvider {
  static final LocalAuthentication localAuth = LocalAuthentication();

  static Future<bool> authenticate() async {
    bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      return false;
    }

    try {
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Please authenticate',
          stickyAuth: true,
          useErrorDialogs: false);
      return didAuthenticate;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        return false;
      }
    }

    return false;
  }
}
