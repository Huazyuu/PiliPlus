import 'package:PiliPlus/utils/utils.dart';

abstract final class AudioConverter {
  static Future<bool> convertM4sToMp3(
    String inputPath,
    String outputPath,
  ) async {
    final result = await Utils.channel.invokeMethod(
      'convertAudio',
      {
        'inputPath': inputPath,
        'outputPath': outputPath,
      },
    );
    return result == true;
  }

  static Future<bool> extractAudioFromVideo(
    String inputPath,
    String outputPath,
  ) async {
    final result = await Utils.channel.invokeMethod(
      'convertAudio',
      {
        'inputPath': inputPath,
        'outputPath': outputPath,
      },
    );
    return result == true;
  }
}
