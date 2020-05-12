import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:background_fetch/background_fetch.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:photo_manager/photo_manager.dart' as photolib;
import 'package:photoprism/api/api.dart';
import 'package:photoprism/common/photo_manager.dart';
import 'package:photoprism/generated/l10n.dart';
import 'package:photoprism/model/album.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoprismUploader {
  PhotoprismUploader(this.photoprismModel) {
    loadPreferences();
    initPlatformState();
    getPhotosToUpload(photoprismModel);

    uploader = FlutterUploader();
    BackgroundFetch.start().then((int status) {
      print('[BackgroundFetch] start success: $status');
    }).catchError((Object e) {
      print('[BackgroundFetch] start FAILURE: $e');
    });

    uploader.progress.listen((UploadTaskProgress progress) {
      //print("Progress: " + progress.progress.toString());
    });

    uploader.result.listen((UploadTaskResponse result) async {
      print('Upload finished.');
      if (result.statusCode == 200) {
        if (result.tag == 'manual') {
          manualUploadFinishedCompleter.complete(0);
        } else {
          print('Auto upload success!');
          uploadFinishedCompleter.complete(0);
        }
      } else {
        if (result.tag == 'manual') {
          manualUploadFinishedCompleter.complete(2);
        } else {
          uploadFinishedCompleter.complete(2);
        }
      }
    }, onError: (Object ex, StackTrace stacktrace) {
      final UploadException exp = ex as UploadException;

      if (exp.tag == 'manual') {
        manualUploadFinishedCompleter.complete(1);
      } else {
        uploadFinishedCompleter.complete(1);
      }
    });
  }

  PhotoprismModel photoprismModel;
  Completer<int> uploadFinishedCompleter;
  Completer<int> manualUploadFinishedCompleter;
  FlutterUploader uploader;
  String deviceName = '';
  Map<String, Album> deviceAlbums = <String, Album>{};

  Future<void> setAutoUpload(bool autoUploadEnabledNew) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('autoUploadEnabled', autoUploadEnabledNew);
    photoprismModel.autoUploadEnabled = autoUploadEnabledNew;
    photoprismModel.notify();
    getPhotosToUpload(photoprismModel);
  }

  Future<void> setAutoUploadLastTimeActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // get time
    final DateTime now = DateTime.now();
    final String currentTime = DateFormat('dd.MM.yyyy – kk:mm').format(now);
    print(currentTime.toString());
    prefs.setString('autoUploadLastTimeActive', currentTime.toString());
    photoprismModel.autoUploadLastTimeCheckedForPhotos = currentTime.toString();
    photoprismModel.notify();
  }

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    photoprismModel.autoUploadEnabled =
        prefs.getBool('autoUploadEnabled') ?? false;
    photoprismModel.autoUploadLastTimeCheckedForPhotos =
        prefs.getString('autoUploadLastTimeActive') ??
            S.of(photoprismModel.context).never;
    photoprismModel.notify();
  }

  /// Starts image file picker, uploads photo(s) and imports them.
  Future<void> selectPhotoAndUpload(BuildContext context) async {
    final S loadingScreenS =
        S.of(photoprismModel.photoprismLoadingScreen.context);
    final List<File> files = await FilePicker.getMultiFile();

    // list for flutter uploader
    final List<FileItem> filesToUpload = <FileItem>[];

    // check if at least one file was selected
    if (files != null) {
      filesToUpload.addAll(files.map<FileItem>((File file) => FileItem(
          filename: basename(file.path),
          savedDir: dirname(file.path),
          fieldname: 'files')));

      if (files.length > 1) {
        photoprismModel.photoprismLoadingScreen
            .showLoadingScreen(loadingScreenS.uploadingPhotos);
      } else {
        photoprismModel.photoprismLoadingScreen
            .showLoadingScreen(loadingScreenS.uploadingPhoto);
      }

      final Random rng = Random.secure();
      String event = '';
      for (int i = 0; i < 12; i++) {
        event += rng.nextInt(9).toString();
      }

      print('Uploading event ' + event);

      final int status = await uploadPhoto(filesToUpload, event);

      if (status == 0) {
        print('Manual upload successful.');
        print('Importing photos..');
        photoprismModel.photoprismLoadingScreen
            .updateLoadingScreen(loadingScreenS.importingPhotos);
        final int status = await Api.importPhotoEvent(photoprismModel, event);

        if (status == 0) {
          await PhotoManager.loadMomentsTime(context, forceReload: true);
          await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
          photoprismModel.photoprismMessage
              .showMessage(loadingScreenS.uploadingAndImportingSuccessful);
        } else if (status == 3) {
          await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
          photoprismModel.photoprismMessage
              .showMessage(loadingScreenS.photoAlreadyImportedOrImportFailed);
        } else {
          await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
          photoprismModel.photoprismMessage
              .showMessage(loadingScreenS.importingFailed);
        }
      } else {
        print('Manual upload failed.');
        await photoprismModel.photoprismLoadingScreen.hideLoadingScreen();
        photoprismModel.photoprismMessage
            .showMessage(loadingScreenS.manualUploadFailed);
      }
    }
  }

  Future<int> uploadPhoto(List<FileItem> filesToUpload, String event) async {
    manualUploadFinishedCompleter = Completer<int>();

    await Api.getNewSession(photoprismModel);
    await uploader.enqueue(
        url: photoprismModel.photoprismUrl + '/api/v1/upload/' + event,
        files: filesToUpload,
        method: UploadMethod.POST,
        showNotification: false,
        tag: 'manual',
        headers: photoprismModel.photoprismAuth.getAuthHeaders());

    return manualUploadFinishedCompleter.future;
  }

  static Future<void> getPhotosToUpload(PhotoprismModel model) async {
    if (!model.autoUploadEnabled) {
      return;
    }

    if (await photolib.PhotoManager.requestPermission()) {
      final List<photolib.AssetPathEntity> albums =
          await photolib.PhotoManager.getAssetPathList(
              type: photolib.RequestType.image);
      final Set<String> photosToUpload = <String>{};
      for (final photolib.AssetPathEntity album in albums) {
        if (model.albumsToUpload.contains(album.id)) {
          List<photolib.AssetEntity> entries = await album.assetList;
          entries = filterForNonUploadedFiles(entries, model);
          photosToUpload.addAll(entries.map((photolib.AssetEntity e) => e.id));
        }
      }
      model.photosToUpload = photosToUpload;
    }
  }

  Future<void> initPlatformState() async {
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.NONE), (String taskId) async {
      try {
        backgroundUpload();
      } finally {
        BackgroundFetch.finish(taskId);
      }
    }).then((int status) {
      print('[BackgroundFetch] configure success: $status');
    }).catchError((Object e) {
      print('[BackgroundFetch] configure ERROR: $e');
    });
  }

  Future<void> backgroundUpload() async {
    print('[BackgroundFetch] Event received');

    if (!photoprismModel.autoUploadEnabled) {
      print('Auto upload disabled.');
      return;
    }

    if (photoprismModel.photoprismUrl == 'https://demo.photoprism.org') {
      print('Auto upload disabled for demo page!');
      return;
    }

    setAutoUploadLastTimeActive();

    deviceName = await getDeviceName();
    final List<Album> deviceAlbumList =
        await Api.searchAlbums(photoprismModel, deviceName);
    if (deviceAlbumList == null) {
      print('Error: album search failed');
      return;
    }
    deviceAlbums = Map<String, Album>.fromEntries(deviceAlbumList
        .map((Album album) => MapEntry<String, Album>(album.name, album)));

    final List<photolib.AssetPathEntity> albumList =
        await photolib.PhotoManager.getAssetPathList(
            type: photolib.RequestType.image);
    for (final photolib.AssetPathEntity album in albumList) {
      if (photoprismModel.albumsToUpload.contains(album.id)) {
        await uploadPhotosFromAlbum(album);
      }
    }

    print('All new photos uploaded.');
  }

  Future<void> uploadPhotosFromAlbum(photolib.AssetPathEntity album) async {
    String albumId;
    final String albumName = '$deviceName – ${album.name}';
    if (deviceAlbums.containsKey(albumName)) {
      albumId = deviceAlbums[albumName].id;
    } else {
      albumId = await Api.createAlbum(albumName, photoprismModel);
      if (albumId == '-1') {
        print('Error: album creation failed');
        return;
      }
    }

    final Map<String, photolib.AssetEntity> assets =
        await getPhotoAssetsAsMap(album.id);
    for (final String id in photoprismModel.photosToUpload) {
      if (!photoprismModel.autoUploadEnabled) {
        print('automatic photo upload was disabled, breaking');
        break;
      }

      if (!assets.containsKey(id)) {
        continue;
      }

      print('########## Upload new photo ##########');
      String filename = await assets[id].titleAsync;

      Uint8List imageBytes = await assets[id].originBytes;

      final String fileExtension = filename.toLowerCase().split('.').last;
      if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
        // JPGs are supported natively by PhotoPrism
      } else if (fileExtension == 'heic' || fileExtension == 'png') {
        imageBytes =
            Uint8List.fromList(await FlutterImageCompress.compressWithList(
          imageBytes,
          minHeight: assets[id].height,
          minWidth: assets[id].width,
          quality: 90,
          format: CompressFormat.jpeg,
          keepExif: true,
        ));
        filename += '.jpg';
      } else {
        saveAndSetPhotosUploadFailed(
            photoprismModel, photoprismModel.photosUploadFailed..add(id));
        continue;
      }

      final String filehash = sha1.convert(imageBytes).toString();

      if (await isPhotoOnServerAndAddToAlbum(
          photoprismModel, id, filehash, albumId)) {
        continue;
      }

      print('Uploading $filename');
      await Api.upload(photoprismModel, filehash, filename, imageBytes);

      // add uploaded photo to shared pref
      if (await Api.importPhotos(
          photoprismModel.photoprismUrl, photoprismModel, filehash)) {
        if (await isPhotoOnServerAndAddToAlbum(
            photoprismModel, id, filehash, albumId)) {
          continue;
        }
      }
      saveAndSetPhotosUploadFailed(
          photoprismModel, photoprismModel.photosUploadFailed..add(id));
      print('############################################');
    }
  }

  static Future<bool> isPhotoOnServerAndAddToAlbum(
      PhotoprismModel model, String id, String filehash, String albumId) async {
    final String photoUUID = await Api.getUuidFromHash(model, filehash);
    if (photoUUID.isEmpty) {
      return false;
    }
    if (await Api.addPhotosToAlbum(albumId, <String>[photoUUID], model) != 0) {
      return false;
    }
    saveAndSetAlreadyUploadedPhotos(
        model, model.alreadyUploadedPhotos..add(id));
    return true;
  }

  static Future<void> saveAndSetAlreadyUploadedPhotos(
      PhotoprismModel model, Set<String> alreadyUploadedPhotos) async {
    model.alreadyUploadedPhotos = alreadyUploadedPhotos;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
        'alreadyUploadedPhotos', alreadyUploadedPhotos.toList());
    await getPhotosToUpload(model);
  }

  static Future<void> saveAndSetPhotosUploadFailed(
      PhotoprismModel model, Set<String> photosUploadFailed) async {
    model.photosUploadFailed = photosUploadFailed;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('photosUploadFailed', photosUploadFailed.toList());
    await getPhotosToUpload(model);
  }

  static Future<void> saveAndSetAlbumsToUpload(
      PhotoprismModel model, Set<String> albumsToUpload) async {
    model.albumsToUpload = albumsToUpload;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('albumsToUpload', albumsToUpload.toList());
    await getPhotosToUpload(model);
  }

  static List<photolib.AssetEntity> filterForNonUploadedFiles(
      List<photolib.AssetEntity> entries, PhotoprismModel model,
      {bool checkServer = false}) {
    final List<photolib.AssetEntity> filteredEntries = <photolib.AssetEntity>[];
    for (final photolib.AssetEntity entry in entries) {
      if (model.alreadyUploadedPhotos.contains(entry.id)) {
        continue;
      }
      if (model.photosUploadFailed.contains(entry.id)) {
        continue;
      }
      filteredEntries.add(entry);
    }
    return filteredEntries;
  }

  static Future<void> clearFailedUploadList(PhotoprismModel model) async {
    await PhotoprismUploader.saveAndSetPhotosUploadFailed(model, <String>{});
  }

  static Future<Map<String, photolib.AssetEntity>> getPhotoAssetsAsMap(
      String id) async {
    final List<photolib.AssetPathEntity> list =
        await photolib.PhotoManager.getAssetPathList(
            type: photolib.RequestType.image);

    for (final photolib.AssetPathEntity album in list) {
      if (album.id == id) {
        return Map<String, photolib.AssetEntity>.fromEntries(
            (await album.assetList).map((photolib.AssetEntity asset) =>
                MapEntry<String, photolib.AssetEntity>(asset.id, asset)));
      }
    }
    return <String, photolib.AssetEntity>{};
  }

  static Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return '';
  }
}
