import 'package:flutter/material.dart';
import 'package:gtmusicplayer/generated/l10n.dart';

import '../utils/preferences.dart';
import 'favorite.dart';
import 'folder.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState(data: _HomeScreenData());
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _topPageCtrl, _bottomPageCtrl;
  final _HomeScreenData data;

  _HomeScreenState({this.data});

  @override
  void initState() {
    super.initState();
    _bottomPageCtrl = PageController(keepPage: false, viewportFraction: 0.35);
    _topPageCtrl = PageController(keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: Colors.blueGrey.shade50,
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: topView(context),
              ),
              SizedBox(
                height: 39,
                child: bottomView(context),
              )
            ],
          ),
        ));
  }

  Widget topView(BuildContext context) {
    return PageView(
      controller: _topPageCtrl,
      onPageChanged: (int pageId) {
        if (_bottomPageCtrl.page != pageId) {
          _bottomPageCtrl.animateToPage(pageId, duration: Duration(milliseconds: 500), curve: Curves.easeOut /**/);
        }
      },
      children: [
        FolderScreen(),
        FavoriteScreen(),
      ],
    );
  }

  Widget bottomSectionWrapper(int index, Widget child) {
    return animatedItemBuilder(
        index,
        GestureDetector(
          onTap: () {
            if (_bottomPageCtrl.page != index) {
              _bottomPageCtrl.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeOut /**/);
              _topPageCtrl.animateToPage(index, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
            }
          },
          child: child,
        ),
        _bottomPageCtrl);
  }

  Widget bottomView(BuildContext context) {
    return PageView(
      controller: _bottomPageCtrl,
      onPageChanged: (int pageId) {
        if (_topPageCtrl.page != pageId) {
          _topPageCtrl.animateToPage(pageId, duration: Duration(milliseconds: 500), curve: Curves.easeOut /**/);
        }
      },
      children: [
        bottomSectionWrapper(
            0, Text(S.of(context).folder, maxLines: 1, style: Theme.of(context).textTheme.headline4.updateSize(-8))),
        bottomSectionWrapper(
            1, Text(S.of(context).favorites, maxLines: 1, style: Theme.of(context).textTheme.headline4.updateSize(-8))),
      ],
    );
  }

  Widget animatedItemBuilder(int index, Widget child, PageController pCtrl) {
    scaleClosure(double scale, int idx) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Transform.scale(
              alignment: idx != 0 ? Alignment.centerLeft : Alignment.centerRight,
              scale: scale,
              child: child,
            ),
          ),
        ],
      );
    }

    return AnimatedBuilder(
        child: child,
        animation: pCtrl,
        builder: (context, child) {
          double value = 1;
          if (pCtrl.position.haveDimensions) {
            value = pCtrl.page - index;
            value = (1 - (value.abs() * 0.7)).clamp(0.0, 1.0);
            return scaleClosure(Curves.easeOut.transform(value), index);
          }
          return scaleClosure(Curves.easeOut.transform(index == 0 ? value : value * 0.3), index);
        });
  }
}

class _HomeScreenData {}
