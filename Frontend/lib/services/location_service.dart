import 'package:geolocator/geolocator.dart';

class LocationService {

  static Future<Position?> getCurrentLocation() async {

    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
          await Geolocator.requestPermission();
    }

    if (permission ==
            LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      return null;
    }

    Position position =
        await Geolocator.getCurrentPosition();

    return position;
  }
}