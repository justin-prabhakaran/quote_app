import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:quote_app/data.dart';

class BookMarks extends StatelessWidget {
  const BookMarks({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BookMarks();
  }
}

class _BookMarks extends StatefulWidget {
  const _BookMarks();

  @override
  State<_BookMarks> createState() => _BookMarksState();
}

class _BookMarksState extends State<_BookMarks> {
  bool _isadLoaded = false;
  late BannerAd _bannerAd;
  List<Map<String, dynamic>> _dblist = [];
  final db = Hive.box('MyDatabase');

  @override
  void initState() {
    final data = db.keys.map((e) {
      final item = db.get(e);
      return {
        'key': e,
        'quote': item['quote'],
        'author': item['author'],
        'type': item['type']
      };
    }).toList();
    setState(() {
      _dblist = data.toList();
      print(_dblist);
    });
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
        request: AdRequest());
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('BookMarks'),
      ),
      body: ListView.builder(
          itemCount: _dblist.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.white,
              elevation: 2,
              child: ListTile(
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      db.delete(_dblist[index]['key']);
                      _dblist.removeAt(index);
                    });
                  },
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.redAccent,
                  ),
                ),
                title: Text('${_dblist[index]['quote']}'),
                subtitle: _dblist[index]['author'] != ''
                    ? Text(
                        '-${_dblist[index]['author']}',
                        style: const TextStyle(color: Colors.grey),
                      )
                    : null,
              ),
            );
          }),
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
