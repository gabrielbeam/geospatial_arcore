// Autogenerated from Pigeon (v10.1.6), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

class Coordinate {
  Coordinate({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  double latitude;

  double longitude;

  double altitude;

  Object encode() {
    return <Object?>[
      latitude,
      longitude,
      altitude,
    ];
  }

  static Coordinate decode(Object result) {
    result as List<Object?>;
    return Coordinate(
      latitude: result[0]! as double,
      longitude: result[1]! as double,
      altitude: result[2]! as double,
    );
  }
}

class _GeospatialARCoreApiCodec extends StandardMessageCodec {
  const _GeospatialARCoreApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is Coordinate) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128: 
        return Coordinate.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class GeospatialARCoreApi {
  /// Constructor for [GeospatialARCoreApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  GeospatialARCoreApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _GeospatialARCoreApiCodec();

  Future<Coordinate> startGeospatialARCoreSession(String arg_apiKey, int arg_horizontalAccuracyLowerLimitInMeters, int arg_cameraTimeoutInSeconds, bool arg_showAdditionalDebugInfo) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.geospatial_arcore.GeospatialARCoreApi.startGeospatialARCoreSession', codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_apiKey, arg_horizontalAccuracyLowerLimitInMeters, arg_cameraTimeoutInSeconds, arg_showAdditionalDebugInfo]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else if (replyList[0] == null) {
      throw PlatformException(
        code: 'null-error',
        message: 'Host platform returned null value for non-null return value.',
      );
    } else {
      return (replyList[0] as Coordinate?)!;
    }
  }
}
