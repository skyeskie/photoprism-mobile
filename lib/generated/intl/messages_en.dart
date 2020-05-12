// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(int howMany) =>
      "${Intl.plural(howMany, one: '1 Element', other: '${howMany} Elements')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addToAlbum": MessageLookupByLibrary.simpleMessage("Add to album"),
        "addingPhotosToAlbum":
            MessageLookupByLibrary.simpleMessage("Adding photos to album.."),
        "addingPhotosToAlbumFailed": MessageLookupByLibrary.simpleMessage(
            "Adding photos to album failed."),
        "addingPhotosToAlbumSuccessful": MessageLookupByLibrary.simpleMessage(
            "Adding photos to album successful."),
        "albums": MessageLookupByLibrary.simpleMessage("Albums"),
        "albumsToUpload":
            MessageLookupByLibrary.simpleMessage("Albums to upload"),
        "archivePhotos":
            MessageLookupByLibrary.simpleMessage("Archive photos.."),
        "archivingPhotosFailed":
            MessageLookupByLibrary.simpleMessage("Archiving photos failed."),
        "authentication":
            MessageLookupByLibrary.simpleMessage("Authentication"),
        "autoUpload": MessageLookupByLibrary.simpleMessage("Auto Upload"),
        "autoUploadLongWarning": MessageLookupByLibrary.simpleMessage(
            "\nWarning: Auto upload is still under development.\nUse it at your own risk!\n"),
        "autoUploadQueue":
            MessageLookupByLibrary.simpleMessage("Auto upload queue"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "confirmDeleteLong": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this album? Your photos will not be deleted."),
        "createAlbum": MessageLookupByLibrary.simpleMessage("Create album"),
        "creatingAlbum":
            MessageLookupByLibrary.simpleMessage("Creating album..."),
        "creatingAlbumFailed":
            MessageLookupByLibrary.simpleMessage("Creating album failed."),
        "deleteAlbum": MessageLookupByLibrary.simpleMessage("Delete album"),
        "deleteAlreadyUploadedPhotosInfo": MessageLookupByLibrary.simpleMessage(
            "Delete already uploaded photos info"),
        "deletingAlbum":
            MessageLookupByLibrary.simpleMessage("Deleting album..."),
        "deletingAlbumFailed":
            MessageLookupByLibrary.simpleMessage("Deleting album failed."),
        "emptyCache": MessageLookupByLibrary.simpleMessage("Empty cache"),
        "enterPhotoprismUrl":
            MessageLookupByLibrary.simpleMessage("Enter Photoprism URL"),
        "errorNoConnection": MessageLookupByLibrary.simpleMessage(
            "Error while sharing: No connection to server!"),
        "failedUploadsList":
            MessageLookupByLibrary.simpleMessage("Failed uploads list"),
        "importingFailed":
            MessageLookupByLibrary.simpleMessage("Importing failed."),
        "importingPhotos":
            MessageLookupByLibrary.simpleMessage("Importing photos.."),
        "lastTimeCheckedForPhotosToBeUploaded":
            MessageLookupByLibrary.simpleMessage(
                "Last time checked for photos to be uploaded"),
        "manualUploadFailed":
            MessageLookupByLibrary.simpleMessage("Manual upload failed."),
        "never": MessageLookupByLibrary.simpleMessage("Never"),
        "newAlbum": MessageLookupByLibrary.simpleMessage("New album"),
        "none": MessageLookupByLibrary.simpleMessage("None"),
        "numberElements": m0,
        "permissionToPhotoLibraryDenied": MessageLookupByLibrary.simpleMessage(
            "Permission to photo library denied!"),
        "photoAlreadyImportedOrImportFailed":
            MessageLookupByLibrary.simpleMessage(
                "Photo already imported or import failed."),
        "photoprismPhoto":
            MessageLookupByLibrary.simpleMessage("Photoprism Photo"),
        "photoprismPhotos":
            MessageLookupByLibrary.simpleMessage("Photoprism Photos"),
        "photoprismUrl": MessageLookupByLibrary.simpleMessage("Photoprism URL"),
        "photos": MessageLookupByLibrary.simpleMessage("Photos"),
        "preparingPhotosForSharing": MessageLookupByLibrary.simpleMessage(
            "Preparing photos for sharing..."),
        "removeFromAlbum":
            MessageLookupByLibrary.simpleMessage("Remove from album"),
        "removingPhotos":
            MessageLookupByLibrary.simpleMessage("Removing photos..."),
        "removingPhotosFromAlbumFailed": MessageLookupByLibrary.simpleMessage(
            "Removing photos from album failed."),
        "renameAlbum": MessageLookupByLibrary.simpleMessage("Rename album"),
        "renamingAlbum":
            MessageLookupByLibrary.simpleMessage("Renaming album..."),
        "renamingAlbumFailed":
            MessageLookupByLibrary.simpleMessage("Renaming album failed."),
        "retryAllFailedUploads":
            MessageLookupByLibrary.simpleMessage("Retry all failed uploads"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "sharePhoto": MessageLookupByLibrary.simpleMessage("Share photo"),
        "sharePhotos": MessageLookupByLibrary.simpleMessage("Share photos"),
        "showFailedUploadsList":
            MessageLookupByLibrary.simpleMessage("Show failed uploads list"),
        "showUploadQueue":
            MessageLookupByLibrary.simpleMessage("Show upload queue"),
        "showUploadedPhotosList":
            MessageLookupByLibrary.simpleMessage("Show uploaded photos list"),
        "triggerAutoUploadManually": MessageLookupByLibrary.simpleMessage(
            "Trigger auto upload manually"),
        "uploadPhoto": MessageLookupByLibrary.simpleMessage("Upload photo"),
        "uploadedPhotosList":
            MessageLookupByLibrary.simpleMessage("Uploaded photos list"),
        "uploadingAndImportingSuccessful": MessageLookupByLibrary.simpleMessage(
            "Uploading and importing successful."),
        "uploadingPhoto":
            MessageLookupByLibrary.simpleMessage("Uploading photo.."),
        "uploadingPhotos":
            MessageLookupByLibrary.simpleMessage("Uploading photos..")
      };
}
