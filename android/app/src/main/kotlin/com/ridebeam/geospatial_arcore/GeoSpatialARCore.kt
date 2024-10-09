// Autogenerated from Pigeon (v10.1.6), do not edit directly.
// See also: https://pub.dev/packages/pigeon


import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun wrapResult(result: Any?): List<Any?> {
  return listOf(result)
}

private fun wrapError(exception: Throwable): List<Any?> {
  if (exception is FlutterError) {
    return listOf(
      exception.code,
      exception.message,
      exception.details
    )
  } else {
    return listOf(
      exception.javaClass.simpleName,
      exception.toString(),
      "Cause: " + exception.cause + ", Stacktrace: " + Log.getStackTraceString(exception)
    )
  }
}

/**
 * Error class for passing custom error details to Flutter via a thrown PlatformException.
 * @property code The error code.
 * @property message The error message.
 * @property details The error details. Must be a datatype supported by the api codec.
 */
class FlutterError (
  val code: String,
  override val message: String? = null,
  val details: Any? = null
) : Throwable()

/** Generated class from Pigeon that represents data sent in messages. */
data class Coordinate (
  val latitude: Double,
  val longitude: Double,
  val altitude: Double

) {
  companion object {
    @Suppress("UNCHECKED_CAST")
    fun fromList(list: List<Any?>): Coordinate {
      val latitude = list[0] as Double
      val longitude = list[1] as Double
      val altitude = list[2] as Double
      return Coordinate(latitude, longitude, altitude)
    }
  }
  fun toList(): List<Any?> {
    return listOf<Any?>(
      latitude,
      longitude,
      altitude,
    )
  }
}

@Suppress("UNCHECKED_CAST")
private object GeospatialARCoreApiCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      128.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let {
          Coordinate.fromList(it)
        }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }
  override fun writeValue(stream: ByteArrayOutputStream, value: Any?)   {
    when (value) {
      is Coordinate -> {
        stream.write(128)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

/** Generated interface from Pigeon that represents a handler of messages from Flutter. */
interface GeospatialARCoreApi {
  fun startGeospatialARCoreSession(apiKey: String, horizontalAccuracyLowerLimitInMeters: Long, cameraTimeoutInSeconds: Long, showAdditionalDebugInfo: Boolean, callback: (Result<Coordinate>) -> Unit)

  companion object {
    /** The codec used by GeospatialARCoreApi. */
    val codec: MessageCodec<Any?> by lazy {
      GeospatialARCoreApiCodec
    }
    /** Sets up an instance of `GeospatialARCoreApi` to handle messages through the `binaryMessenger`. */
    @Suppress("UNCHECKED_CAST")
    fun setUp(binaryMessenger: BinaryMessenger, api: GeospatialARCoreApi?) {
      run {
        val channel = BasicMessageChannel<Any?>(binaryMessenger, "dev.flutter.pigeon.geospatial_arcore.GeospatialARCoreApi.startGeospatialARCoreSession", codec)
        if (api != null) {
          channel.setMessageHandler { message, reply ->
            val args = message as List<Any?>
            val apiKeyArg = args[0] as String
            val horizontalAccuracyLowerLimitInMetersArg = args[1].let { if (it is Int) it.toLong() else it as Long }
            val cameraTimeoutInSecondsArg = args[2].let { if (it is Int) it.toLong() else it as Long }
            val showAdditionalDebugInfoArg = args[3] as Boolean
            api.startGeospatialARCoreSession(apiKeyArg, horizontalAccuracyLowerLimitInMetersArg, cameraTimeoutInSecondsArg, showAdditionalDebugInfoArg) { result: Result<Coordinate> ->
              val error = result.exceptionOrNull()
              if (error != null) {
                reply.reply(wrapError(error))
              } else {
                val data = result.getOrNull()
                reply.reply(wrapResult(data))
              }
            }
          }
        } else {
          channel.setMessageHandler(null)
        }
      }
    }
  }
}
