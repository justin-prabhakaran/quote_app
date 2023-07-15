import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import '../data.dart';

class Jokes extends StatelessWidget {
  const Jokes({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Jokes();
  }
}

class _Jokes extends StatefulWidget {
  const _Jokes();

  @override
  State<_Jokes> createState() => _JokesState();
}

class _JokesState extends State<_Jokes> {
  late BannerAd _bannerAd;
  bool _isadLoaded = false;
  late List _jokes;
  late ScrollController _scrollcontroller;
  GlobalKey<AnimatedListState> _key = GlobalKey();

  @override
  void initState() {
    _jokes = [];
    _scrollcontroller = ScrollController();
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

  Future<void> _getJoke() async {
    var url = Uri.parse(
        'https://v2.jokeapi.dev/joke/Any?blacklistFlags=nsfw,religious,political,racist,sexist,explicit&type=twopart');
    var res = await http.get(url);
    var js = jsonDecode(res.body);
    debugPrint(res.body);
    _jokes.add(Joke(js['category'], js['setup'], js['delivery'], false));
    _key.currentState!.insertItem(_jokes.length - 1);
  }

  void refresh(int index) async {
    await Future.delayed(const Duration(seconds: 2));
    if (!_jokes[index].visibility) {
      setState(() {
        _jokes[index].visibility = true;
        debugPrint('changed : ${_jokes[index].visibility}');
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Random Jokes'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Flexible(
            child: AnimatedList(
                key: _key,
                initialItemCount: _jokes.length,
                controller: _scrollcontroller,
                itemBuilder: (context, index, animation) {
                  refresh(index);
                  return SlideTransition(
                    position: animation.drive(Tween<Offset>(
                        begin: const Offset(0, 1), end: const Offset(0, 0))),
                    child: Card(
                      elevation: 1,
                      child: ListTile(
                        title: Text(
                          _jokes[index].setup,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.redAccent),
                        ),
                        subtitle: Visibility(
                          visible: _jokes[index].visibility,
                          child: Text(
                            _jokes[index].delivery,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        closeManually: true,
        overlayOpacity: 0,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Add',
              onTap: () {
                _getJoke();
                _scrollcontroller.animateTo(
                    _scrollcontroller.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              }),
          SpeedDialChild(
              child: const Icon(Icons.delete),
              label: 'Remove All',
              onTap: () {
                _jokes.clear();
                _key.currentState!
                    .removeAllItems((context, animation) => SizedBox());
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
}
