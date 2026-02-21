import 'dart:developer' as developer;

class Logger {
  static const String _name = 'StateAsset';

  static void d(String message) {
    developer.log(message, name: '$_name/D');
  }

  static void i(String message) {
    developer.log(message, name: '$_name/I');
  }

  static void w(String message) {
    developer.log(message, name: '$_name/W');
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: '$_name/E',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void v(String message) {
    developer.log(message, name: '$_name/V');
  }
}
