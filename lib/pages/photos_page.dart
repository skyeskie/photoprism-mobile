import 'package:cached_network_image/cached_network_image.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photoprism/api/api.dart';
import 'package:photoprism/common/album_manager.dart';
import 'package:photoprism/common/hexcolor.dart';
import 'package:photoprism/common/photo_manager.dart';
import 'package:photoprism/common/transparent_route.dart';
import 'package:photoprism/generated/l10n.dart';
import 'package:photoprism/model/moments_time.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:photoprism/pages/photoview.dart';
import 'package:photoprism/widgets/selectable_tile.dart';
import 'package:provider/provider.dart';

class PhotosPage extends StatelessWidget {
  const PhotosPage({Key key, this.albumId}) : super(key: key);

  final int albumId;

  static Future<void> archiveSelectedPhotos(BuildContext context) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    final List<String> selectedPhotos = model
        .gridController.selection.selectedIndexes
        .map<String>((int element) =>
            PhotoManager.getPhotos(context, null)[element].photoUUID)
        .toList();

    PhotoManager.archivePhotos(context, selectedPhotos);
  }

  static void _selectAlbumBottomSheet(BuildContext context) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    if (model.albums == null) {
      AlbumManager.loadAlbums(context, 0);
    }

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext bc) {
          return ListView.builder(
              itemCount: model.albums == null ? 0 : model.albums.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return ListTile(
                  title: Text(model.albums[index].name),
                  onTap: () {
                    addPhotosToAlbum(index, context);
                  },
                );
              });
        });
  }

  static Future<void> _sharePhotos(BuildContext context) async {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    final Map<String, List<int>> photos = <String, List<int>>{};
    model.photoprismLoadingScreen
        .showLoadingScreen(S.of(context).preparingPhotosForSharing);
    for (final int index in model.gridController.selection.selectedIndexes) {
      final List<int> bytes =
          await Api.downloadPhoto(model, model.photos[index].fileHash);
      if (bytes == null) {
        model.photoprismLoadingScreen.hideLoadingScreen();
        return;
      }
      photos[model.photos[index].fileHash + '.jpg'] = bytes;
    }
    model.photoprismLoadingScreen.hideLoadingScreen();
    Share.files(S.of(context).photoprismPhotos, photos, 'image/jpg');
  }

  static Future<void> addPhotosToAlbum(
      int albumId, BuildContext context) async {
    Navigator.pop(context);

    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    final List<String> selectedPhotos = model
        .gridController.selection.selectedIndexes
        .map<String>((int element) =>
            PhotoManager.getPhotos(context, null)[element].photoUUID)
        .toList();

    model.gridController.clear();
    AlbumManager.addPhotosToAlbum(context, albumId, selectedPhotos);
  }

  Text getMonthFromOffset(
      BuildContext context, ScrollController scrollController) {
    for (final MomentsTime m
        in PhotoManager.getCummulativeMonthCount(context)) {
      if (m.count >= PhotoManager.getPhotoIndexInScrollView(context, albumId)) {
        return Text('${m.month}/${m.year}');
      }
    }
    return const Text('');
  }

  Widget displayPhotoIfUrlLoaded(BuildContext context, int index) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    final String imageUrl =
        PhotoManager.getPhotoThumbnailUrl(context, index, albumId);
    if (imageUrl == null) {
      PhotoManager.loadPhoto(context, index, albumId);
      return Container(
        color: Colors.grey[300],
      );
    }
    return CachedNetworkImage(
      httpHeaders: model.photoprismAuth.getAuthHeaders(),
      alignment: Alignment.center,
      fit: BoxFit.contain,
      imageUrl: imageUrl,
      placeholder: (BuildContext context, String url) => Container(
        color: Colors.grey[300],
      ),
      errorWidget: (BuildContext context, String url, Object error) =>
          Icon(Icons.error),
    );
  }

  static AppBar appBar(BuildContext context) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);

    return AppBar(
      title: model.gridController.selection.selectedIndexes.isNotEmpty
          ? Text(
              model.gridController.selection.selectedIndexes.length.toString())
          : const Text('PhotoPrism'),
      backgroundColor: HexColor(model.applicationColor),
      leading: model.gridController.selection.selectedIndexes.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                model.gridController.clear();
              },
            )
          : null,
      actions: model.gridController.selection.selectedIndexes.isNotEmpty
          ? <Widget>[
              IconButton(
                icon: const Icon(Icons.archive),
                tooltip: S.of(context).archivePhotos,
                onPressed: () {
                  archiveSelectedPhotos(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: S.of(context).addToAlbum,
                onPressed: () {
                  _selectAlbumBottomSheet(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: S.of(context).sharePhotos,
                onPressed: () {
                  _sharePhotos(context);
                },
              ),
            ]
          : <Widget>[
              PopupMenuButton<int>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Text(S.of(context).uploadPhoto),
                  )
                ],
                onSelected: (int choice) {
                  if (choice == 0) {
                    model.photoprismUploader.selectPhotoAndUpload(context);
                  }
                },
              ),
            ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    final ScrollController _scrollController = model.scrollController;

    final DragSelectGridViewController gridController =
        Provider.of<PhotoprismModel>(context)
            .photoprismCommonHelper
            .getGridController();

    final int tileCount = PhotoManager.getPhotosCount(context, albumId);

    //if (Photos.getPhotoList(context, albumId).length == 0) {
    //  return IconButton(onPressed: () => {}, icon: Icon(Icons.add));
    //}
    return RefreshIndicator(child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
      if (albumId == null && model.momentsTime == null) {
        PhotoManager.loadMomentsTime(context);
        return const Text('', key: ValueKey<String>('photosGridView'));
      }

      return DraggableScrollbar.semicircle(
        labelTextBuilder: albumId == null
            ? (double offset) => getMonthFromOffset(context, _scrollController)
            : null,
        heightScrollThumb: 50.0,
        controller: _scrollController,
        child: DragSelectGridView(
            padding: const EdgeInsets.only(top: 0),
            key: const ValueKey<String>('photosGridView'),
            scrollController: _scrollController,
            gridController: gridController,
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: orientation == Orientation.portrait ? 3 : 6,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: tileCount,
            itemBuilder: (BuildContext context, int index, bool selected) {
              return SelectableTile(
                  key: const ValueKey<String>('PhotoTile'),
                  index: index,
                  context: context,
                  gridController: gridController,
                  selected: selected,
                  onTap: () {
                    Provider.of<PhotoprismModel>(context)
                        .photoprismCommonHelper
                        .setPhotoViewScaleState(PhotoViewScaleState.initial);
                    Navigator.push(
                        context,
                        TransparentRoute(
                          builder: (BuildContext context) =>
                              FullscreenPhotoGallery(index, albumId),
                        ));
                  },
                  child: Hero(
                    tag: index.toString(),
                    createRectTween: (Rect begin, Rect end) {
                      return RectTween(begin: begin, end: end);
                    },
                    child: displayPhotoIfUrlLoaded(
                      context,
                      index,
                    ),
                  ));
            }),
      );
    }), onRefresh: () async {
      if (albumId == null) {
        return await PhotoManager.loadMomentsTime(context, forceReload: true);
      } else {
        await AlbumManager.loadAlbums(context, 0,
            forceReload: true, loadPhotosForAlbumId: albumId);
      }
    });
  }
}
