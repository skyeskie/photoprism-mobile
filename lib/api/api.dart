import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:photoprism/model/album.dart';
import 'package:photoprism/model/moments_time.dart';
import 'package:photoprism/model/photo.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:provider/provider.dart';

class Api {
  static Future<dynamic> httpAuth(PhotoprismModel model, Function call) async {
    dynamic response = await call();
    if ((response as http.BaseResponse).statusCode == 401) {
      if (await getNewSession(model)) {
        response = await call();
      }
    }
    return response;
  }

  static Future<String> createAlbum(
      String albumName, PhotoprismModel model) async {
    final String body = '{"AlbumName":"' + albumName + '"}';

    try {
      final http.Response response = await httpAuth(
          model,
          () => http.post(model.photoprismUrl + '/api/v1/albums',
              body: body,
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;

      if (response.statusCode == 200) {
        final dynamic bodyjson = json.decode(response.body);
        return bodyjson['AlbumUUID'].toString();
      } else {
        return '-1';
      }
    } catch (_) {
      return '-1';
    }
  }

  static Future<List<Album>> searchAlbums(
      PhotoprismModel model, String query) async {
    try {
      final http.Response response = await httpAuth(
          model,
          () => http.get(
              model.photoprismUrl + '/api/v1/albums?count=1000&q=$query',
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
      if (response.statusCode != 200) {
        return null;
      }
      return json
          .decode(response.body)
          .map<Album>(
              (dynamic value) => Album.fromJson(value as Map<String, dynamic>))
          .toList() as List<Album>;
    } catch (_) {
      return null;
    }
  }

  static Future<int> renameAlbum(
      String albumId, String newAlbumName, PhotoprismModel model) async {
    final String body = '{"AlbumName":"' + newAlbumName + '"}';

    try {
      final http.Response response = await httpAuth(
          model,
          () => http.put(model.photoprismUrl + '/api/v1/albums/' + albumId,
              body: body,
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;

      if (response.statusCode == 200) {
        return 0;
      } else {
        return 2;
      }
    } catch (_) {
      return 1;
    }
  }

  static Future<int> deleteAlbum(String albumId, PhotoprismModel model) async {
    final String body = '{"albums":["' + albumId + '"]}';

    try {
      final http.Response response = await httpAuth(
          model,
          () => http.post(model.photoprismUrl + '/api/v1/batch/albums/delete',
              body: body,
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;

      if (response.statusCode == 200) {
        return 0;
      } else {
        return 2;
      }
    } catch (_) {
      return 1;
    }
  }

  static Future<int> addPhotosToAlbum(
      String albumId, List<String> photoUUIDs, PhotoprismModel model) async {
    // wrap uuids in double quotes

    final List<String> photoUUIDsWrapped =
        photoUUIDs.map<String>((String uuid) => '"' + uuid + '"').toList();

    final String body = '{"photos":' + photoUUIDsWrapped.toString() + '}';

    try {
      final http.Response response = await httpAuth(
          model,
          () => http.post(
              model.photoprismUrl + '/api/v1/albums/' + albumId + '/photos',
              body: body,
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
      if (response.statusCode == 200) {
        return 0;
      } else {
        return 2;
      }
    } catch (_) {
      return 1;
    }
  }

  static Future<int> removePhotosFromAlbum(
      String albumId, List<String> photoUUIDs, PhotoprismModel model) async {
    // wrap uuids in double quotes
    final List<String> photoUUIDsWrapped =
        photoUUIDs.map<String>((String uuid) => '"' + uuid + '"').toList();

    final String body = '{"photos":' + photoUUIDsWrapped.toString() + '}';

    final http.Client client = http.Client();
    try {
      final http.Request request = http.Request(
          'DELETE',
          Uri.parse(
              model.photoprismUrl + '/api/v1/albums/' + albumId + '/photos'));
      request.headers['Content-Type'] = 'application/json';
      request.body = body;
      model.photoprismAuth.getAuthHeaders().forEach((String k, String v) {
        request.headers[k] = v;
      });
      final http.StreamedResponse response =
          await httpAuth(model, () => client.send(request))
              as http.StreamedResponse;
      if (response.statusCode == 200) {
        return 0;
      } else {
        return 2;
      }
    } catch (_) {
      return 1;
    }
  }

  static Future<int> archivePhotos(
      List<String> photoUUIDs, PhotoprismModel model) async {
    // wrap uuids in double quotes
    final List<String> photoUUIDsWrapped =
        photoUUIDs.map<String>((String uuid) => '"' + uuid + '"').toList();

    final String body = '{"photos":' + photoUUIDsWrapped.toString() + '}';

    try {
      final http.Response response = await httpAuth(
          model,
          () => http.post(model.photoprismUrl + '/api/v1/batch/photos/archive',
              body: body,
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
      if (response.statusCode == 200) {
        return 0;
      } else {
        return 2;
      }
    } catch (_) {
      return 1;
    }
  }

  static Future<bool> importPhotos(
      String photoprismUrl, PhotoprismModel model, String fileHash) async {
    try {
      final http.Response response = await httpAuth(
          model,
          () => http.post(photoprismUrl + '/api/v1/import/upload/$fileHash',
              body: '{}',
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
      return response.statusCode == 200;
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  static Future<int> importPhotoEvent(
      PhotoprismModel model, String event) async {
    try {
      final http.Response response = await httpAuth(
          model,
          () => http.post(
              model.photoprismUrl + '/api/v1/import/upload/' + event,
              body: '{}',
              headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
      if (response.statusCode == 200) {
        // TODO: Check if import is really successful
        if (response.body == '{"message":"import completed in 0 s"}') {
          return 3;
        } else {
          return 0;
        }
      } else {
        return 2;
      }
    } catch (_) {
      return 1;
    }
  }

  static Future<List<MomentsTime>> loadMomentsTime(BuildContext context) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    final http.Response response = await httpAuth(
        model,
        () => http.get(model.photoprismUrl + '/api/v1/moments/time',
            headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
    if (response.statusCode != 200) {
      return <MomentsTime>[];
    }
    return json
        .decode(response.body)
        .map<MomentsTime>((dynamic value) =>
            MomentsTime.fromJson(value as Map<String, dynamic>))
        .toList() as List<MomentsTime>;
  }

  static Future<Map<int, Photo>> loadPhotos(
      BuildContext context, int albumId, int offset) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);

    String albumIdUrlParam = '';
    if (albumId != null &&
        model.albums != null &&
        model.albums[albumId] != null) {
      albumIdUrlParam = model.albums[albumId].id;
    }

    final http.Response response = await httpAuth(
        model,
        () => http.get(
            model.photoprismUrl +
                '/api/v1/photos' +
                '?count=100' +
                '&offset=' +
                offset.toString() +
                '&album=' +
                albumIdUrlParam,
            headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
    final List<dynamic> parsed = json.decode(response.body) as List<dynamic>;
    return Map<int, Photo>.fromIterables(
        List<int>.generate(parsed.length, (int i) => i + offset),
        parsed
            .map<Photo>(
                (dynamic json) => Photo.fromJson(json as Map<String, dynamic>))
            .toList());
  }

  static Future<Map<int, Album>> loadAlbums(
      BuildContext context, int offset) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);

    final http.Response response = await httpAuth(
        model,
        () => http.get(
            model.photoprismUrl +
                '/api/v1/albums' +
                '?count=1000' +
                '&offset=' +
                offset.toString(),
            headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
    final List<dynamic> parsed = json.decode(response.body) as List<dynamic>;

    return Map<int, Album>.fromIterables(
        List<int>.generate(parsed.length, (int i) => i + offset),
        parsed
            .map<Album>(
                (dynamic json) => Album.fromJson(json as Map<String, dynamic>))
            .toList());
  }

  static Future<String> getUuidFromHash(
      PhotoprismModel model, String filehash) async {
    final http.Response response = await httpAuth(
        model,
        () => http.get(model.photoprismUrl + '/api/v1/files/$filehash',
            headers: model.photoprismAuth.getAuthHeaders())) as http.Response;
    if (response.statusCode != 200) {
      return '';
    }
    final Map<String, dynamic> parsed =
        json.decode(response.body) as Map<String, dynamic>;
    if (parsed.containsKey('PhotoUUID')) {
      return parsed['PhotoUUID'] as String;
    }
    return parsed['Photo']['PhotoUUID'] as String;
  }

  static Future<bool> upload(PhotoprismModel model, String fileId,
      String fileName, List<int> file) async {
    try {
      final http.MultipartRequest request = http.MultipartRequest(
          'POST', Uri.parse('${model.photoprismUrl}/api/v1/upload/$fileId'));
      request.files.add(http.MultipartFile.fromBytes('files', file,
          filename: fileName, contentType: MediaType('image', 'jpeg')));
      request.headers.addAll(model.photoprismAuth.getAuthHeaders());
      final http.StreamedResponse response =
          await httpAuth(model, () => request.send()) as http.StreamedResponse;

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Upload failed: statusCode=${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Upload failed: $e');
      return false;
    }
  }

  static Future<bool> getNewSession(PhotoprismModel model) async {
    if (model.photoprismAuth.enabled == false) {
      return false;
    }

    final http.Response response = await httpAuth(
            model,
            () => http.post(model.photoprismUrl + '/api/v1/session',
                headers: model.photoprismAuth.getAuthHeaders(),
                body:
                    '{"email":"${model.photoprismAuth.user}", "password":"${model.photoprismAuth.password}"}'))
        as http.Response;
    if (response.statusCode == 200 &&
        response.headers.containsKey('x-session-token')) {
      await model.photoprismAuth
          .setSessionToken(response.headers['x-session-token']);
      return true;
    }
    return false;
  }

  static Future<List<int>> downloadPhoto(
      PhotoprismModel model, String fileHash) async {
    final http.Response response = await Api.httpAuth(
        model,
        () => http.get(
            Uri.parse(model.photoprismUrl + '/api/v1/download/' + fileHash),
            headers: model.photoprismAuth.getAuthHeaders())) as http.Response;

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      model.photoprismMessage
          .showMessage('Error while sharing: No connection to server!'.tr());
    }
    return null;
  }
}
