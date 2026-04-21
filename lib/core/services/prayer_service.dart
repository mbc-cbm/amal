import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provides prayer time calculations and location access.
/// Actual prayer time computation will use an Islamic calculation library
/// or a backend API wired in a future sprint.
class PrayerService {
  /// Requests location permission and returns the device position.
  /// Returns null if permission is denied.
  Future<Position?> getCurrentPosition() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return null;

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
  }

  /// Checks whether the device's location services are enabled.
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Opens the device settings so the user can enable location.
  Future<void> openSettings() => openAppSettings();
}
