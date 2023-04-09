import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:akarak/api/api.dart';
import 'package:akarak/models/model.dart';
import 'package:path/path.dart' as path;

enum ProtectedUploadType { image, audio }

class FileRepository {
  ///Protected Upload Build
  static Future<Map<String, dynamic>> protectedUploadBuild(
      {required File file,
      String? externalId,
      required ProtectedUploadType type}) async {
    Uint8List bytes = file.readAsBytesSync();
    String bs4str = base64Encode(bytes);
    // ByteData.view(bytes.buffer)
    Map<String, dynamic> params = {
      "externalId": externalId,
      "fileName": file.path.split('/').last,
      "extension": path.extension(file.path),
      "uploadType": type.index,
      "size": bytes.elementSizeInBytes,
      "data": bs4str,
    };
    return params;
  }

  ///Protected Upload File
  static Future<ResultApiModel> protectedUpload(
      {required File file,
      String? externalId,
      required ProtectedUploadType type,
      progress}) async {
    Uint8List bytes = file.readAsBytesSync();
    String bs4str = base64Encode(bytes);
    // ByteData.view(bytes.buffer)
    Map<String, dynamic> params = {
      "externalId": externalId,
      "fileName": file.path.split('/').last,
      "extension": path.extension(file.path),
      "uploadType": type.index,
      "size": bytes.elementSizeInBytes,
      "data": bs4str,
    };
    return await Api.requestProtectedUpload(params, progress);
  }
}
