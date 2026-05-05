import 'dart:io';
import 'dart:typed_data';

import 'package:dart_lame/dart_lame.dart';
import 'package:path/path.dart' as p;
import 'package:PiliPlus/utils/utils.dart';

abstract final class AudioConverter {
  /// m4s -> m4a (remux via MediaCodec, no re-encoding)
  static Future<bool> convertM4sToM4a(
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

  /// 0.mp4 -> m4a (extract audio via MediaCodec remux)
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

  /// m4a -> mp3 via LAME
  static Future<bool> convertM4aToMp3(
    String inputPath,
    String outputPath,
  ) async {
    // Step 1: Decode AAC to raw PCM via native MediaCodec
    final pcmPath = '${p.dirname(outputPath)}/tmp_decode.pcm';
    final decodeResult = await Utils.channel.invokeMethod(
      'decodeAacToPcm',
      {
        'inputPath': inputPath,
        'outputPath': pcmPath,
      },
    );
    if (decodeResult != true) return false;

    try {
      // Step 2: Read PCM and encode to MP3 via LAME
      final pcmBytes = await File(pcmPath).readAsBytes();

      // PCM is 16-bit signed LE, stereo, 44100Hz
      // Convert to Int16List for LAME
      final sampleCount = pcmBytes.lengthInBytes ~/ 2;
      final pcmSamples = Int16List(sampleCount);
      final byteData = ByteData.view(pcmBytes.buffer);
      for (int i = 0; i < sampleCount; i++) {
        pcmSamples[i] = byteData.getInt16(i * 2, Endian.little);
      }

      // Split into left/right channels (interleaved stereo)
      final channelCount = sampleCount ~/ 2;
      final leftChannel = Int16List(channelCount);
      final rightChannel = Int16List(channelCount);
      for (int i = 0; i < channelCount; i++) {
        leftChannel[i] = pcmSamples[i * 2];
        rightChannel[i] = pcmSamples[i * 2 + 1];
      }

      final encoder = LameMp3Encoder(
        sampleRate: 44100,
        numChannels: 2,
        bitRate: 192,
      );

      // Encode in chunks
      const chunkSize = 4096;
      final outputFile = File(outputPath);
      final sink = outputFile.openWrite();

      for (int offset = 0; offset < channelCount; offset += chunkSize) {
        final end = (offset + chunkSize).clamp(0, channelCount);
        final leftChunk = leftChannel.sublist(offset, end);
        final rightChunk = rightChannel.sublist(offset, end);
        final mp3Frame = await encoder.encode(
          leftChannel: leftChunk,
          rightChannel: rightChunk,
        );
        sink.add(mp3Frame);
      }

      // Flush remaining
      final remaining = await encoder.flush();
      if (remaining.isNotEmpty) {
        sink.add(remaining);
      }

      await sink.flush();
      await sink.close();
      await encoder.close();

      return outputFile.existsSync() && outputFile.lengthSync() > 0;
    } finally {
      try {
        await File(pcmPath).delete();
      } catch (_) {}
    }
  }
}
