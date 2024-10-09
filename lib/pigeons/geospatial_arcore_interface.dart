import 'package:pigeon/pigeon.dart';

class Coordinate {
  final double latitude; 
  final double longitude;
  final double altitude;

  Coordinate({required this.latitude, required this.longitude, required this.altitude});
}

@HostApi()
abstract class GeospatialARCoreApi {
  @async
  Coordinate startGeospatialARCoreSession(String apiKey, int horizontalAccuracyLowerLimitInMeters,
      int cameraTimeoutInSeconds, bool showAdditionalDebugInfo);
}
