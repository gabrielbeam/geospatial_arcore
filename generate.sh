dart run pigeon \
  --input lib/pigeons/geospatial_arcore_interface.dart \
  --dart_out lib/geospatial_arcore.dart \
  --kotlin_out ./android/app/src/main/kotlin/com/ridebeam/geospatial_arcore/GeoSpatialARCore.kt \
  --java_package "com.ridebeam.geospatial_arcore"