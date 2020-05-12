import 'package:flutter/material.dart';
import 'package:photoprism/api/api.dart';
import 'package:photoprism/common/album_manager.dart';
import 'package:photoprism/common/photo_manager.dart';
import 'package:photoprism/generated/l10n.dart';
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
    _model.photoprismLoadingScreen.showLoadingScreen(
        S.of(_model.photoprismLoadingScreen.context).renamingAlbum);

    // rename remote album
    final int status = await Api.renameAlbum(
        _album.id, _renameAlbumTextFieldController.text, _model);

    await AlbumManager.loadAlbums(context, 0, forceReload: true);

    await _model.photoprismLoadingScreen.hideLoadingScreen();
    // close rename dialog
    Navigator.pop(context);

    // check renaming success
    if (status != 0) {
      _model.photoprismMessage.showMessage(
          S.of(_model.photoprismLoadingScreen.context).renamingAlbumFailed);
    }
  }

  Future<void> _deleteAlbum(BuildContext context) async {
    _model.photoprismLoadingScreen.showLoadingScreen(
        S.of(_model.photoprismLoadingScreen.context).deletingAlbum);

    // delete remote album
    final int status = await Api.deleteAlbum(_album.id, _model);

    await _model.photoprismLoadingScreen.hideLoadingScreen();

    // close delete dialog
    Navigator.pop(context);
    // check if successful
    if (status != 0) {
      _model.photoprismMessage.showMessage(
          S.of(_model.photoprismLoadingScreen.context).deletingAlbumFailed);
    } else {
      // go back to albums view
      await AlbumManager.loadAlbums(context, 0, forceReload: true);
      Navigator.pop(context);
    }
  }

  Future<void> _removePhotosFromAlbum(BuildContext context) async {
    _model.photoprismLoadingScreen.showLoadingScreen(
        S.of(_model.photoprismLoadingScreen.context).removingPhotos);

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
      _model.photoprismMessage.showMessage(S
          .of(_model.photoprismLoadingScreen.context)
          .removingPhotosFromAlbumFailed);
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
                            child: Text(S.of(context).removeFromAlbum),
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
                            child: Text(S.of(context).renameAlbum),
                          ),
                          PopupMenuItem<int>(
                            value: 1,
                            child: Text(S.of(context).deleteAlbum),
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
            title: Text(S.of(context).renameAlbum),
            content: TextField(
              controller: _renameAlbumTextFieldController,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(S.of(context).renameAlbum),
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
            title: Text(S.of(context).deleteAlbum),
            content: Text(S.of(context).confirmDeleteLong),
            actions: <Widget>[
              FlatButton(
                child: Text(S.of(context).cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(S.of(context).deleteAlbum),
                onPressed: () {
                  _deleteAlbum(albumContext);
                },
              )
            ],
          );
        });
  }
}
