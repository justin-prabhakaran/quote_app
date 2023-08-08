import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'data.dart';
import 'nav.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  await Hive.openBox('MyDatabase');
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.light(useMaterial3: true).copyWith(
      //     scaffoldBackgroundColor: Colors.white,
      //     appBarTheme: const AppBarTheme(backgroundColor: Colors.white)),
      theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Garamond',
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.white)),
      title: 'Boost Your Life',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BannerAd _bannerAd;
  bool _isadLoaded = false;
  final db = Hive.box('MyDatabase');
  bool _isLoading = false;

  //====================================================
  final List<Quote> _quote = [];
  final GlobalKey<AnimatedListState> _key = GlobalKey();
  final ScrollController _scrollcontroller = ScrollController();
  late final sub;

  Future<void> getQoute() async {
    var url = Uri.parse('https://api.quotable.io/quotes/random');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var js = jsonDecode(res.body);
      _quote.add(Quote(js[0]['content'], js[0]['author']));
      _key.currentState!.insertItem(_quote.length - 1);
    } else {
      setState(() {
        _isLoading = true;
      });
    }
  }

  @override
  void initState() {
    loadAd();
    super.initState();
    sub = Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.mobile ||
          event == ConnectivityResult.wifi) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _quote.clear();
    sub.cancel();
    super.dispose();
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
          ad.dispose();
          setState(() {
            _isadLoaded = false;
          });
        }, onAdClosed: (ad) {
          setState(() {
            _isadLoaded = false;
          });
        }),
        request: const AdRequest());
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavBar(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Random Quotes'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: AnimatedList(
                      key: _key,
                      controller: _scrollcontroller,
                      initialItemCount: _quote.length,
                      itemBuilder: (context, index, animation) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween<Offset>(
                              begin: const Offset(0, 1),
                              end: const Offset(0, 0),
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            color: Colors.white,
                            elevation: 1,
                            child: Slidable(
                              startActionPane: ActionPane(
                                extentRatio: 0.4,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      db.add({
                                        'quote': _quote[index].qoute,
                                        'author': _quote[index].author,
                                        'type': 'Random'
                                      });
                                      var _snackbar = const SnackBar(
                                        content: Center(
                                          child: Text(
                                            "Added to Bookmarks successfully",
                                            style:
                                                TextStyle(color: Colors.white),
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
                                    label: 'Bookmark',
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10.0),
                                        bottomLeft: Radius.circular(10.0)),
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                extentRatio: 0.3,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      _quote.removeAt(index);
                                      _key.currentState!.removeItem(
                                          index,
                                          (context, animation) =>
                                              const SizedBox());
                                      setState(() {});
                                      var _snackbar = const SnackBar(
                                        content: Center(
                                          child: Text(
                                            "Deleted Successfully",
                                            style:
                                                TextStyle(color: Colors.white),
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
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: Text('${_quote[index].qoute}'),
                                subtitle: Text(
                                  '  - ${_quote[index].author}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                onLongPress: () async {
                                  await Clipboard.setData(ClipboardData(
                                      text:
                                          '${_quote[index].qoute}   \n- ${_quote[index].author}'));
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
              getQoute();
              _scrollcontroller.animateTo(
                  _scrollcontroller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            },
          ),
          SpeedDialChild(
              child: const Icon(Icons.delete),
              label: 'Remove All',
              onTap: () {
                _quote.clear();
                _key.currentState!
                    .removeAllItems((context, animation) => const SizedBox());
              })
        ],
      ),
      bottomNavigationBar: _isadLoaded
          ? SizedBox(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            )
          : const SizedBox(),
    );
  }
}
