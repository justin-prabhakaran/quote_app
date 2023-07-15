import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../data.dart';

class Stoic extends StatelessWidget {
  const Stoic({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Stoic();
  }
}

class _Stoic extends StatefulWidget {
  const _Stoic();

  @override
  State<_Stoic> createState() => _StoicState();
}

class _StoicState extends State<_Stoic> {
  final db = Hive.box('MyDatabase');
  ScrollController _scrollController = ScrollController();
  List _insQoute = [];
  GlobalKey<AnimatedListState> _key = GlobalKey();
  late BannerAd _bannerAd;
  bool _isadLoaded = false;

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  void loadAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: ForAd.adUnitID,
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            _isadLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          setState(() {
            ad.dispose();
            _isadLoaded = false;
          });
        }),
        request: const AdRequest());
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Stoic Quotes'),
      ),
      body: Column(
        children: [
          Flexible(
            child: AnimatedList(
                key: _key,
                controller: _scrollController,
                initialItemCount: _insQoute.length,
                itemBuilder: (context, index, animation) {
                  return SlideTransition(
                    position: animation.drive(Tween<Offset>(
                        begin: const Offset(0, 1), end: const Offset(0, 0))),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      color: Colors.white,
                      elevation: 3,
                      child: Slidable(
                        startActionPane: ActionPane(
                          extentRatio: 0.4,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                db.add({
                                  'quote': _insQoute[index].qoute,
                                  'author': _insQoute[index].author,
                                  'type': 'Stoic Quotes'
                                });
                                var _snackbar = const SnackBar(
                                  content: Center(
                                    child: Text(
                                      "Added to Bookmarks successfully",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 1),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(_snackbar);
                              },
                              backgroundColor: Colors.green,
                              label: 'Bookmarks',
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0)),
                            )
                          ],
                        ),
                        endActionPane: ActionPane(
                          extentRatio: 0.3,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                _insQoute.removeAt(index);
                                _key.currentState!.removeItem(
                                    index, (context, animation) => SizedBox());
                                var _snackbar = const SnackBar(
                                  content: Center(
                                    child: Text(
                                      "Deleted successfully",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 1),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(_snackbar);
                              },
                              backgroundColor: Colors.redAccent,
                              label: 'Delete',
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0)),
                            )
                          ],
                        ),
                        child: ListTile(
                          title: Text('${_insQoute[index].qoute}'),
                          subtitle: Text(
                            '  - ${_insQoute[index].author}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onLongPress: () async {
                            await Clipboard.setData(ClipboardData(
                                text:
                                    '${_insQoute[index].qoute} \n - ${_insQoute[index].author}'));
                            var _snackbar = const SnackBar(
                              content: Center(
                                child: Text(
                                  "Copied Successfully",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              backgroundColor: Colors.green,
                              elevation: 10,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(_snackbar);
                          },
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        closeManually: true,
        overlayOpacity: 0,
        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Add',
              onTap: () {
                _insQuoteAdd();
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              }),
          SpeedDialChild(
              child: const Icon(Icons.delete),
              label: 'Remove All',
              onTap: () {
                _insQoute.clear();
                _key.currentState!
                    .removeAllItems((context, animation) => SizedBox());
                setState(() {});
              })
        ],
      ),
      bottomNavigationBar: _isadLoaded
          ? SizedBox(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(
                ad: _bannerAd,
              ),
            )
          : const SizedBox(),
    );
  }

  Future<void> _insQuoteAdd() async {
    var url = Uri.parse('https://api.themotivate365.com/stoic-quote');
    var res = await http.get(url);
    var by = utf8.decode(res.bodyBytes);
    by = by.replaceAll(RegExp(r'[@_-]'), '');
    var js = jsonDecode(by);
    _insQoute.add(Quote(js['quote'], js['author']));
    _key.currentState!.insertItem(_insQoute.length - 1);
  }
}
