import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_manager/photo_manager.dart' as photolib;
import 'package:photoprism/common/photoprism_uploader.dart';
import 'package:photoprism/generated/l10n.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:photoprism/pages/auto_upload_queue.dart';
import 'package:photoprism/widgets/auth_dialog.dart';
import 'package:photoprism/widgets/multi_select_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  final TextEditingController _urlTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);

    return Scaffold(
        appBar: AppBar(
          title: const Text('PhotoPrism'),
        ),
        body: Container(
            //width: double.maxFinite,
            child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(S.of(context).photoprismUrl),
              subtitle: Text(model.photoprismUrl),
              leading: Container(
                width: 10,
                alignment: Alignment.center,
                child: Icon(Icons.public),
              ),
              onTap: () {
                _settingsDisplayUrlDialog(context);
              },
            ),
            ListTile(
              title: Text(S.of(context).authentication),
              leading: Container(
                width: 10,
                alignment: Alignment.center,
                child: Icon(Icons.vpn_key),
              ),
              onTap: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => AuthDialog(
                        context: context,
                      )),
            ),
            ListTile(
              title: Text(S.of(context).emptyCache),
              leading: Container(
                width: 10,
                alignment: Alignment.center,
                child: Icon(Icons.delete),
              ),
              onTap: () {
                emptyCache(context);
              },
            ),
            SwitchListTile(
              title: Text(S.of(context).autoUpload),
              secondary: const Icon(Icons.cloud_upload),
              value: model.autoUploadEnabled,
              onChanged: (bool newState) async {
                final bool result =
                    await photolib.PhotoManager.requestPermission();
                if (result) {
                  model.photoprismUploader.setAutoUpload(newState);
                  if (newState) {
                    configureAlbumsToUpload(context);
                  }
                } else {
                  model.photoprismMessage.showMessage(S
                      .of(model.photoprismLoadingScreen.context)
                      .permissionToPhotoLibraryDenied);
                }
              },
            ),
            ListTile(
              title: Text(S.of(context).autoUploadLongWarning),
            ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).albumsToUpload),
                subtitle: _albumsToUploadText(),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.folder),
                ),
                onTap: () {
                  configureAlbumsToUpload(context);
                },
              ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).lastTimeCheckedForPhotosToBeUploaded),
                subtitle: Text(model.autoUploadLastTimeCheckedForPhotos),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.sync),
                ),
              ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).deleteAlreadyUploadedPhotosInfo),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.delete_sweep),
                ),
                onTap: () {
                  deleteUploadInfo(context);
                },
              ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).retryAllFailedUploads),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.refresh),
                ),
                onTap: () {
                  PhotoprismUploader.clearFailedUploadList(model);
                },
              ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).triggerAutoUploadManually),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.sync),
                ),
                onTap: () {
                  model.photoprismUploader.backgroundUpload();
                },
              ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).showUploadQueue),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.sort),
                ),
                trailing: Text(model.photosToUpload.length.toString()),
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext ctx) => FileList(model,
                            files: model.photosToUpload.toList(),
                            title: S.of(context).autoUploadQueue)),
                  );
                },
              ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).showUploadedPhotosList),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.sort),
                ),
                trailing: Text(model.alreadyUploadedPhotos.length.toString()),
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext ctx) => FileList(model,
                            files: model.alreadyUploadedPhotos.toList(),
                            title: S.of(context).uploadedPhotosList)),
                  );
                },
              ),
            if (model.autoUploadEnabled)
              ListTile(
                title: Text(S.of(context).showFailedUploadsList),
                leading: Container(
                  width: 10,
                  alignment: Alignment.center,
                  child: Icon(Icons.warning),
                ),
                trailing: Text(model.photosUploadFailed.length.toString()),
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (BuildContext ctx) => FileList(model,
                            files: model.photosUploadFailed.toList(),
                            title: S.of(context).failedUploadsList)),
                  );
                },
              ),
            const AboutListTile()
          ],
        )));
  }

  Future<void> deleteUploadInfo(BuildContext context) async {
    await PhotoprismUploader.saveAndSetAlreadyUploadedPhotos(
        Provider.of<PhotoprismModel>(context), <String>{});
    await PhotoprismUploader.saveAndSetPhotosUploadFailed(
        Provider.of<PhotoprismModel>(context), <String>{});
  }

  Future<void> configureAlbumsToUpload(BuildContext context) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);

    if (!await photolib.PhotoManager.requestPermission()) {
      model.photoprismMessage.showMessage(S
          .of(model.photoprismLoadingScreen.context)
          .permissionToPhotoLibraryDenied);
      return;
    }

    final List<photolib.AssetPathEntity> assets =
        await photolib.PhotoManager.getAssetPathList();
    assets.sort((photolib.AssetPathEntity a, photolib.AssetPathEntity b) =>
        b.assetCount.compareTo(a.assetCount));

    final Set<String> result = await showDialog(
        context: context,
        builder: (BuildContext context) => MultiSelectDialog(
            titles: assets
                .map((photolib.AssetPathEntity asset) => asset.name)
                .toList(),
            subtitles: assets
                .map((photolib.AssetPathEntity asset) =>
                    S.of(context).numberElements(asset.assetCount))
                .toList(),
            ids: assets
                .map((photolib.AssetPathEntity asset) => asset.id)
                .toList(),
            selected: model.albumsToUpload.toList()));

    if (result == null) {
      return;
    }
    if (!const SetEquality<String>().equals(result, model.albumsToUpload)) {
      print('album selection updated');
      PhotoprismUploader.saveAndSetAlbumsToUpload(model, result);
      PhotoprismUploader.getPhotosToUpload(model);
    }
  }

  Future<void> _settingsDisplayUrlDialog(BuildContext context) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    _urlTextFieldController.text = model.photoprismUrl;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S.of(context).enterPhotoprismUrl),
            content: TextField(
              key: const ValueKey<String>('photoprismUrlTextField'),
              controller: _urlTextFieldController,
              decoration: const InputDecoration(
                  hintText: 'https://demo.photoprism.org'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(S.of(context).save),
                onPressed: () {
                  setNewPhotoprismUrl(context, _urlTextFieldController.text);
                },
              )
            ],
          );
        });
  }

  Future<void> setNewPhotoprismUrl(BuildContext context, String url) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    Navigator.of(context).pop();
    await model.photoprismCommonHelper.setPhotoprismUrl(url);
    model.photoprismRemoteConfigLoader.loadApplicationColor();
    emptyCache(context);
  }

  static Future<void> emptyCache(BuildContext context) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove('momentsTime');
    sp.remove('photos');
    sp.remove('albums');
    if (model.albums != null) {
      for (final int albumId in model.albums.keys) {
        sp.remove('photos' + albumId.toString());
      }
    }
    model.photos = null;
    model.momentsTime = null;
    model.albums = null;
    await DefaultCacheManager().emptyCache();
  }

  Widget _albumsToUploadText() => FutureBuilder<List<photolib.AssetPathEntity>>(
      future: photolib.PhotoManager.getAssetPathList(),
      builder: (BuildContext context,
          AsyncSnapshot<List<photolib.AssetPathEntity>> snapshot) {
        if (snapshot.data == null) {
          return const Text('');
        }
        final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
        String selectedAlbums = '';
        for (final photolib.AssetPathEntity album in snapshot.data) {
          if (model.albumsToUpload.contains(album.id)) {
            selectedAlbums += '${album.name}, ';
          }
        }
        if (selectedAlbums.isEmpty) {
          return Text(S.of(context).none);
        }
        return Text(selectedAlbums.substring(0, selectedAlbums.length - 2));
      });
}
