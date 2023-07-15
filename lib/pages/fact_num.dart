import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:quote_app/data.dart';

class FactNum extends StatelessWidget {
  const FactNum({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FactNum();
  }
}

class _FactNum extends StatefulWidget {
  const _FactNum({super.key});

  @override
  State<_FactNum> createState() => _FactNumState();
}

class _FactNumState extends State<_FactNum> {
  late BannerAd _bannerAd;
  bool _isadLoaded = false;
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
  bool _isLoading = true;
  List _facts = [];

  Future<void> _getFact() async {
    var url = Uri.parse('http://numbersapi.com/random/math');
    var res = await http.get(url);
    _facts.add(res.body);
  }

  _getfacts() {
    for (int i = 0; i < 10; i++) {
      _getFact();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getfacts();
    Future.delayed(const Duration(seconds: 5), () {
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
        title: const Text('Facts In Numbers'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
              cardsCount: _facts.length,
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
                            _facts[index],
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
                                'quote': _facts[index],
                                'author': '',
                                'type': 'Facts In Numbers'
                              });
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(_snackadd);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_outlined),
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: _facts[index]));
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
                print(_facts.length);
                if (cur == _facts.length - 3 && _facts.length < 30) {
                  print('called');
                  _getfacts();
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
