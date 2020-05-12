import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photoprism/common/hexcolor.dart';
import 'package:photoprism/generated/l10n.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:photoprism/pages/albums_page.dart';
import 'package:photoprism/pages/photos_page.dart';
import 'package:photoprism/pages/settings_page.dart';
import 'package:provider/provider.dart';
// use this for debugging animations
// import 'package:flutter/scheduler.dart' show timeDilation;

void main() {
  // use this for debugging animations
  // timeDilation = 10.0;
  runApp(
    ChangeNotifierProvider<PhotoprismModel>(
      create: (BuildContext context) => PhotoprismModel(),
      child: PhotoprismApp(),
    ),
  );
}

class PhotoprismApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color applicationColor =
        HexColor(Provider.of<PhotoprismModel>(context).applicationColor);

    return MaterialApp(
      // ignore: always_specify_types
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'PhotoPrism',
      theme: ThemeData(
        primaryColor: applicationColor,
        accentColor: applicationColor,
        colorScheme: ColorScheme.light(
          primary: applicationColor,
        ),
        textSelectionColor: applicationColor,
        textSelectionHandleColor: applicationColor,
        cursorColor: applicationColor,
        inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: applicationColor))),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  MainPage() : _pageController = PageController(initialPage: 0);
  final PageController _pageController;

  @override
  Widget build(BuildContext context) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    model.photoprismLoadingScreen.context = context;

    if (!model.dataFromCacheLoaded) {
      model.loadDataFromCache(context);
      return Scaffold(
        appBar: AppBar(
          title: const Text('PhotoPrism'),
        ),
      );
    }

    return Scaffold(
      appBar: model.selectedPageIndex == 0 ? PhotosPage.appBar(context) : null,
      body: PageView(
          controller: _pageController,
          children: <Widget>[
            const PhotosPage(albumId: null),
            const AlbumsPage(),
            SettingsPage(),
          ],
          physics: const NeverScrollableScrollPhysics()),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.photo),
            title: Text(S.of(context).photos),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.photo_album),
            title: Text(S.of(context).albums),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            title: Text(S.of(context).settings),
          ),
        ],
        currentIndex: model.selectedPageIndex,
        onTap: (int index) {
          if (index != 0) {
            model.gridController.clear();
          }
          _pageController.jumpToPage(index);
          model.photoprismCommonHelper.setSelectedPageIndex(index);
        },
      ),
    );
  }
}
