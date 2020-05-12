// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S();
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  String get addingPhotosToAlbum {
    return Intl.message(
      'Adding photos to album..',
      name: 'addingPhotosToAlbum',
      desc: '',
      args: [],
    );
  }

  String get addingPhotosToAlbumFailed {
    return Intl.message(
      'Adding photos to album failed.',
      name: 'addingPhotosToAlbumFailed',
      desc: '',
      args: [],
    );
  }

  String get addingPhotosToAlbumSuccessful {
    return Intl.message(
      'Adding photos to album successful.',
      name: 'addingPhotosToAlbumSuccessful',
      desc: '',
      args: [],
    );
  }

  String get addToAlbum {
    return Intl.message(
      'Add to album',
      name: 'addToAlbum',
      desc: '',
      args: [],
    );
  }

  String get albums {
    return Intl.message(
      'Albums',
      name: 'albums',
      desc: '',
      args: [],
    );
  }

  String get albumsToUpload {
    return Intl.message(
      'Albums to upload',
      name: 'albumsToUpload',
      desc: '',
      args: [],
    );
  }

  String get archivePhotos {
    return Intl.message(
      'Archive photos..',
      name: 'archivePhotos',
      desc: '',
      args: [],
    );
  }

  String get archivingPhotosFailed {
    return Intl.message(
      'Archiving photos failed.',
      name: 'archivingPhotosFailed',
      desc: '',
      args: [],
    );
  }

  String get authentication {
    return Intl.message(
      'Authentication',
      name: 'authentication',
      desc: '',
      args: [],
    );
  }

  String get autoUpload {
    return Intl.message(
      'Auto Upload',
      name: 'autoUpload',
      desc: '',
      args: [],
    );
  }

  String get autoUploadLongWarning {
    return Intl.message(
      '\nWarning: Auto upload is still under development.\nUse it at your own risk!\n',
      name: 'autoUploadLongWarning',
      desc: '',
      args: [],
    );
  }

  String get autoUploadQueue {
    return Intl.message(
      'Auto upload queue',
      name: 'autoUploadQueue',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get confirmDeleteLong {
    return Intl.message(
      'Are you sure you want to delete this album? Your photos will not be deleted.',
      name: 'confirmDeleteLong',
      desc: '',
      args: [],
    );
  }

  String get createAlbum {
    return Intl.message(
      'Create album',
      name: 'createAlbum',
      desc: '',
      args: [],
    );
  }

  String get creatingAlbum {
    return Intl.message(
      'Creating album...',
      name: 'creatingAlbum',
      desc: '',
      args: [],
    );
  }

  String get creatingAlbumFailed {
    return Intl.message(
      'Creating album failed.',
      name: 'creatingAlbumFailed',
      desc: '',
      args: [],
    );
  }

  String get deleteAlbum {
    return Intl.message(
      'Delete album',
      name: 'deleteAlbum',
      desc: '',
      args: [],
    );
  }

  String get deleteAlreadyUploadedPhotosInfo {
    return Intl.message(
      'Delete already uploaded photos info',
      name: 'deleteAlreadyUploadedPhotosInfo',
      desc: '',
      args: [],
    );
  }

  String get deletingAlbum {
    return Intl.message(
      'Deleting album...',
      name: 'deletingAlbum',
      desc: '',
      args: [],
    );
  }

  String get deletingAlbumFailed {
    return Intl.message(
      'Deleting album failed.',
      name: 'deletingAlbumFailed',
      desc: '',
      args: [],
    );
  }

  String get emptyCache {
    return Intl.message(
      'Empty cache',
      name: 'emptyCache',
      desc: '',
      args: [],
    );
  }

  String get enterPhotoprismUrl {
    return Intl.message(
      'Enter Photoprism URL',
      name: 'enterPhotoprismUrl',
      desc: '',
      args: [],
    );
  }

  String get errorNoConnection {
    return Intl.message(
      'Error while sharing: No connection to server!',
      name: 'errorNoConnection',
      desc: '',
      args: [],
    );
  }

  String get failedUploadsList {
    return Intl.message(
      'Failed uploads list',
      name: 'failedUploadsList',
      desc: '',
      args: [],
    );
  }

  String get importingFailed {
    return Intl.message(
      'Importing failed.',
      name: 'importingFailed',
      desc: '',
      args: [],
    );
  }

  String get importingPhotos {
    return Intl.message(
      'Importing photos..',
      name: 'importingPhotos',
      desc: '',
      args: [],
    );
  }

  String get lastTimeCheckedForPhotosToBeUploaded {
    return Intl.message(
      'Last time checked for photos to be uploaded',
      name: 'lastTimeCheckedForPhotosToBeUploaded',
      desc: '',
      args: [],
    );
  }

  String get manualUploadFailed {
    return Intl.message(
      'Manual upload failed.',
      name: 'manualUploadFailed',
      desc: '',
      args: [],
    );
  }

  String get never {
    return Intl.message(
      'Never',
      name: 'never',
      desc: '',
      args: [],
    );
  }

  String get newAlbum {
    return Intl.message(
      'New album',
      name: 'newAlbum',
      desc: '',
      args: [],
    );
  }

  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  String numberElements(num howMany) {
    return Intl.plural(
      howMany,
      one: '1 Element',
      other: '$howMany Elements',
      name: 'numberElements',
      desc: '',
      args: [howMany],
    );
  }

  String get permissionToPhotoLibraryDenied {
    return Intl.message(
      'Permission to photo library denied!',
      name: 'permissionToPhotoLibraryDenied',
      desc: '',
      args: [],
    );
  }

  String get photoAlreadyImportedOrImportFailed {
    return Intl.message(
      'Photo already imported or import failed.',
      name: 'photoAlreadyImportedOrImportFailed',
      desc: '',
      args: [],
    );
  }

  String get photoprismPhoto {
    return Intl.message(
      'Photoprism Photo',
      name: 'photoprismPhoto',
      desc: '',
      args: [],
    );
  }

  String get photoprismPhotos {
    return Intl.message(
      'Photoprism Photos',
      name: 'photoprismPhotos',
      desc: '',
      args: [],
    );
  }

  String get photoprismUrl {
    return Intl.message(
      'Photoprism URL',
      name: 'photoprismUrl',
      desc: '',
      args: [],
    );
  }

  String get photos {
    return Intl.message(
      'Photos',
      name: 'photos',
      desc: '',
      args: [],
    );
  }

  String get preparingPhotosForSharing {
    return Intl.message(
      'Preparing photos for sharing...',
      name: 'preparingPhotosForSharing',
      desc: '',
      args: [],
    );
  }

  String get removeFromAlbum {
    return Intl.message(
      'Remove from album',
      name: 'removeFromAlbum',
      desc: '',
      args: [],
    );
  }

  String get removingPhotos {
    return Intl.message(
      'Removing photos...',
      name: 'removingPhotos',
      desc: '',
      args: [],
    );
  }

  String get removingPhotosFromAlbumFailed {
    return Intl.message(
      'Removing photos from album failed.',
      name: 'removingPhotosFromAlbumFailed',
      desc: '',
      args: [],
    );
  }

  String get renameAlbum {
    return Intl.message(
      'Rename album',
      name: 'renameAlbum',
      desc: '',
      args: [],
    );
  }

  String get renamingAlbum {
    return Intl.message(
      'Renaming album...',
      name: 'renamingAlbum',
      desc: '',
      args: [],
    );
  }

  String get renamingAlbumFailed {
    return Intl.message(
      'Renaming album failed.',
      name: 'renamingAlbumFailed',
      desc: '',
      args: [],
    );
  }

  String get retryAllFailedUploads {
    return Intl.message(
      'Retry all failed uploads',
      name: 'retryAllFailedUploads',
      desc: '',
      args: [],
    );
  }

  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  String get sharePhoto {
    return Intl.message(
      'Share photo',
      name: 'sharePhoto',
      desc: '',
      args: [],
    );
  }

  String get sharePhotos {
    return Intl.message(
      'Share photos',
      name: 'sharePhotos',
      desc: '',
      args: [],
    );
  }

  String get showFailedUploadsList {
    return Intl.message(
      'Show failed uploads list',
      name: 'showFailedUploadsList',
      desc: '',
      args: [],
    );
  }

  String get showUploadedPhotosList {
    return Intl.message(
      'Show uploaded photos list',
      name: 'showUploadedPhotosList',
      desc: '',
      args: [],
    );
  }

  String get showUploadQueue {
    return Intl.message(
      'Show upload queue',
      name: 'showUploadQueue',
      desc: '',
      args: [],
    );
  }

  String get triggerAutoUploadManually {
    return Intl.message(
      'Trigger auto upload manually',
      name: 'triggerAutoUploadManually',
      desc: '',
      args: [],
    );
  }

  String get uploadedPhotosList {
    return Intl.message(
      'Uploaded photos list',
      name: 'uploadedPhotosList',
      desc: '',
      args: [],
    );
  }

  String get uploadingAndImportingSuccessful {
    return Intl.message(
      'Uploading and importing successful.',
      name: 'uploadingAndImportingSuccessful',
      desc: '',
      args: [],
    );
  }

  String get uploadingPhoto {
    return Intl.message(
      'Uploading photo..',
      name: 'uploadingPhoto',
      desc: '',
      args: [],
    );
  }

  String get uploadingPhotos {
    return Intl.message(
      'Uploading photos..',
      name: 'uploadingPhotos',
      desc: '',
      args: [],
    );
  }

  String get uploadPhoto {
    return Intl.message(
      'Upload photo',
      name: 'uploadPhoto',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (Locale supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}