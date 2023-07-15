import 'dart:ui';

class DataColors {
  static final darkblue = Color(0xff264653);
  static final midblue = Color(0xFF023E8A);
  static final blue = Color(0xFF0077B6);
  static final lighblue = Color(0xFF0077B6);
  static final white = Color(0xFFf1faee);
}

class Quote {
  var _qoute;
  var _author;

  Quote(this._qoute, this._author);

  get author => _author;

  get qoute => _qoute;
}

class Joke {
  var _category;
  var _setup;
  var _delivery;
  var _visibility;

  Joke(this._category, this._setup, this._delivery, this._visibility);

  get delivery => _delivery;

  get visibility => _visibility;

  set visibility(value) {
    _visibility = value;
  }

  get setup => _setup;

  get category => _category;
}

class ForAd {
  static const adUnitID = 'ca-app-pub-6607951901321875/5775636202';
}
