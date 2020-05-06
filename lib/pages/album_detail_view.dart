import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photoprism/api/api.dart';
import 'package:photoprism/common/album_manager.dart';
import 'package:photoprism/common/photo_manager.dart';
import 'package:photoprism/model/album.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:photoprism/pages/photos_page.dart';
import 'package:provider/provider.dart';

class AlbumDetailView extends StatelessWidget {
  AlbumDetailView(this._album, this._albumId, BuildContext context)
      : _renameAlbumTextFieldController = TextEditingController(),
        _model = Provider.of<PhotoprismModel>(context);

  final PhotoprismModel _model;
  final Album _album;
  final int _albumId;
  final TextEditingController _renameAlbumTextFieldController;

  Future<void> _renameAlbum(BuildContext context) async {
    _model.photoprismLoadingScreen.showLoadingScreen('Renaming album...'.tr());

    // rename remote album
    final int status = await Api.renameAlbum(
        _album.id, _renameAlbumTextFieldController.text, _model);

    await AlbumManager.loadAlbums(context, 0, forceReload: true);

    await _model.photoprismLoadingScreen.hideLoadingScreen();
    // close rename dialog
    Navigator.pop(context);

    // check renaming success
    if (status != 0) {
      _model.photoprismMessage.showMessage('Renaming album failed.'.tr());
    }
  }

  Future<void> _deleteAlbum(BuildContext context) async {
    _model.photoprismLoadingScreen.showLoadingScreen('Deleting album...'.tr());

    // delete remote album
    final int status = await Api.deleteAlbum(_album.id, _model);

    await _model.photoprismLoadingScreen.hideLoadingScreen();

    // close delete dialog
    Navigator.pop(context);
    // check if successful
    if (status != 0) {
      _model.photoprismMessage.showMessage('Deleting album failed.'.tr());
    } else {
      // go back to albums view
      await AlbumManager.loadAlbums(context, 0, forceReload: true);
      Navigator.pop(context);
    }
  }

  Future<void> _removePhotosFromAlbum(BuildContext context) async {
    _model.photoprismLoadingScreen.showLoadingScreen('Removing photos...'.tr());

    // save all selected photos in list
    final List<String> selectedPhotos = <String>[];
    for (final int photoId in _model.gridController.selection.selectedIndexes) {
      selectedPhotos
          .add(PhotoManager.getPhotos(context, _albumId)[photoId].photoUUID);
    }

    // remove remote photos from album
    final int status =
        await Api.removePhotosFromAlbum(_album.id, selectedPhotos, _model);

    // check if successful
    if (status != 0) {
      _model.photoprismMessage
          .showMessage('Removing photos from album failed.'.tr());
    } else {
      AlbumManager.loadAlbums(context, 0,
          forceReload: true, loadPhotosForAlbumId: _albumId);
    }
    // deselect selected photos
    _model.gridController.clear();
    _model.photoprismLoadingScreen.hideLoadingScreen();
  }

  @override
  Widget build(BuildContext context) {
    final int _selectedPhotosCount =
        _model.gridController.selection.selectedIndexes.length;
    return NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: _selectedPhotosCount > 0
                    ? Text(_selectedPhotosCount.toString())
                    : Text(_album.name),
                centerTitle: _selectedPhotosCount > 0 ? false : null,
              ),
              leading: _selectedPhotosCount > 0
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _model.gridController.clear();
                      },
                    )
                  : null,
              actions: _selectedPhotosCount > 0
                  ? <Widget>[
                      PopupMenuButton<int>(
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<int>>[
                          PopupMenuItem<int>(
                            value: 2,
                            child: const Text('Remove from album').tr(),
                          ),
                        ],
                        onSelected: (int choice) {
                          _removePhotosFromAlbum(context);
                        },
                      ),
                    ]
                  : <Widget>[
                      // overflow menu
                      PopupMenuButton<int>(
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<int>>[
                          PopupMenuItem<int>(
                            value: 0,
                            child: const Text('Rename album').tr(),
                          ),
                          PopupMenuItem<int>(
                            value: 1,
                            child: const Text('Delete album').tr(),
                          ),
                        ],
                        onSelected: (int choice) {
                          if (choice == 0) {
                            _showRenameAlbumDialog(context);
                          } else if (choice == 1) {
                            _showDeleteAlbumDialog(context);
                          }
                        },
                      ),
                    ],
            ),
          ];
        },
        body: Container(
            color: Colors.white, child: PhotosPage(albumId: _albumId)));
  }

  Future<void> _showRenameAlbumDialog(BuildContext context) async {
    _renameAlbumTextFieldController.text = _album.name;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Rename album').tr(),
            content: TextField(
              controller: _renameAlbumTextFieldController,
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Cancel').tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: const Text('Rename album').tr(),
                onPressed: () {
                  _renameAlbum(context);
                },
              )
            ],
          );
        });
  }

  Future<void> _showDeleteAlbumDialog(BuildContext albumContext) async {
    return showDialog(
        context: albumContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete album?').tr(),
            content: Text('Are you sure you want to delete this album?'.tr() +
                'Your photos will not be deleted.'.tr()),
            actions: <Widget>[
              FlatButton(
                child: const Text('Cancel').tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: const Text('Delete album').tr(),
                onPressed: () {
                  _deleteAlbum(albumContext);
                },
              )
            ],
          );
        });
  }
}
