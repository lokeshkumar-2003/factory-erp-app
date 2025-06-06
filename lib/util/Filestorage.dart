import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileStorage {
  static Future<String> getDownloadDirectory() async {
    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      Directory? directory;

      if (Platform.isAndroid) {
        // Common public download path
        directory = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        // Use applicationDocumentsDirectory for iOS
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null && await directory.exists()) {
        return directory.path;
      } else {
        throw Exception("Unable to access download directory");
      }
    } else {
      throw Exception("Storage permission denied");
    }
  }

  static Future<String> getExternalDocumentPath() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory directory;

    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final exPath = directory.path;
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<File> writeBinaryFile(Uint8List bytes, String filename) async {
    final path = await getExternalDocumentPath();
    File file = File('$path/$filename');
    return file.writeAsBytes(bytes);
  }
}
