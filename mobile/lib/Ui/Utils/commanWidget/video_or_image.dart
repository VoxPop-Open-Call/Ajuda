import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageOrVideo {

  //image compress
  static Future<File> getCompressedImage(File file) async {
    String targetPath = file.parent.path +
        '/' +
        (DateTime
            .now()
            .millisecondsSinceEpoch).toString() +
        '.jpeg';

    File? f = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
    );

    file.deleteSync();

    return f!;
  }

  //video compress
//   static Future<File> getCompressedVideo(File file) async {
//     MediaInfo info = await VideoCompress.compressVideo(
//       file.path,
//       quality: VideoQuality.LowQuality,
//       deleteOrigin: true,
//       frameRate: 30,
//       includeAudio: true,
//     );
//
//     final renamedFile = await info.file.copy(info.file.parent.path +
//         '/' +
//         (DateTime.now().millisecondsSinceEpoch).toString() +
//         '.mp4');
//
//     info.file.deleteSync();
//
//     return renamedFile;
// //
// //    String workingDir = file.parent.path;
// //    String outputFile =
// //        "$workingDir/${DateTime.now().millisecondsSinceEpoch}.mp4";
// //
// //    await FlutterFFmpeg()
// //        .execute("-i ${file.path} -r 15 -b:v 200K -b:a 16K $outputFile");
// //
// //    // delete the original file
// //    file.delete();
// //
// //    return File(outputFile);
//   }

  //size of mb
  static Future<double> getSizeInMb(File file) async {
    int videoSize = await file.length();
    return videoSize / 1000000;
  }

}