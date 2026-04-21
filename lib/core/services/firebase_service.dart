import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

/// Thin wrapper around Firebase initialisation.
/// Call [FirebaseService.initialize] once in main() before runApp().
abstract final class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
