import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

abstract final class AudioConverter {
  static Future<bool> convertM4sToMp3(
    String inputPath,
    String outputPath,
  ) async {
    final session = await FFmpegKit.execute(
      '-i "$inputPath" -vn -acodec libmp3lame -q:a 2 "$outputPath"',
    );
    final returnCode = await session.getReturnCode();
    return ReturnCode.isSuccess(returnCode);
  }

  static Future<bool> extractAudioFromVideo(
    String inputPath,
    String outputPath,
  ) async {
    final session = await FFmpegKit.execute(
      '-i "$inputPath" -vn -acodec libmp3lame -q:a 2 "$outputPath"',
    );
    final returnCode = await session.getReturnCode();
    return ReturnCode.isSuccess(returnCode);
  }
}
