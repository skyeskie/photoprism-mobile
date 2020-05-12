import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photoprism/common/hexcolor.dart';
import 'package:photoprism/gen/codegen_loader.g.dart';
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
  runApp(EasyLocalization(
    child: ChangeNotifierProvider<PhotoprismModel>(
      create: (BuildContext context) => PhotoprismModel(),
      child: PhotoprismApp(),
    ),
    supportedLocales: const <Locale>[
      Locale('en'),
      Locale('de'),
      Locale('nl'),
      Locale('ru'),
    ],
    assetLoader: const CodegenLoader(),
    path: 'assets/lang',
  ));
}

class PhotoprismApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color applicationColor =
        HexColor(Provider.of<PhotoprismModel>(context).applicationColor);

    //Can force locale with following
    //context.locale = const Locale('de');

    return MaterialApp(
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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
            icon: Icon(Icons.photo),
            title: const Text('Photos').tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            title: const Text('Albums').tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: const Text('Settings').tr(),
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
