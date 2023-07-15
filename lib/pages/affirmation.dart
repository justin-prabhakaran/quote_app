import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:quote_app/data.dart';

class Affirmation extends StatelessWidget {
  const Affirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Affirmation();
  }
}

class _Affirmation extends StatefulWidget {
  const _Affirmation();

  @override
  State<_Affirmation> createState() => _AffirmationState();
}

class _AffirmationState extends State<_Affirmation> {
  final db = Hive.box('MyDatabase');
  final _snackadd = const SnackBar(
    content: Center(
      child: Text(
        "Added to Bookmarks successfully",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
    backgroundColor: Colors.green,
    elevation: 10,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 1),
  );

  final List _affirmation = [];
  late BannerAd _bannerAd;
  bool _isadLoaded = false;
  bool _isLoading = true;

  Future<void> _getAffirmation() async {
    var url = Uri.parse('https://www.affirmations.dev/');
    http.Response res = await http.get(url);
    var js = jsonDecode(res.body);
    setState(() {
      _affirmation.add(js['affirmation']);
    });
  }

  _getAffirmations() {
    for (int i = 0; i < 10; i++) {
      _getAffirmation();
    }
  }

  @override
  void initState() {
    loadAd();
    super.initState();
    _getAffirmations();
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isLoading = false;
      });
    });
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
            _isadLoaded = false;
            ad.dispose();
          });
        }),
        request: const AdRequest());
    _bannerAd.load();
  }

  @override
  void dispose() {
    _affirmation.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Affirmation'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _body(context),
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

  Widget _body(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: _height * 0.5,
            width: _width,
            child: CardSwiper(
              allowedSwipeDirection:
                  AllowedSwipeDirection.symmetric(horizontal: true),
              isLoop: false,
              backCardOffset: const Offset(0, 20),
              numberOfCardsDisplayed: 4,
              cardsCount: _affirmation.length,
              cardBuilder: (context, index, x, y) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 1))
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _affirmation[index],
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.bookmark_border_outlined),
                            onPressed: () {
                              db.add({
                                'quote': _affirmation[index],
                                'author': '',
                                'type': 'Affirmation'
                              });
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(_snackadd);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_outlined),
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: _affirmation[index]));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
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
                              ));
                            },
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
              onSwipe: (pre, cur, dir) {
                print(pre);
                print(_affirmation.length);
                if (cur == _affirmation.length - 3 &&
                    _affirmation.length < 30) {
                  print('called');
                  _getAffirmations();
                }
                return true;
              },
            ),
          ),
        ),
      ],
    );
  }
}
