import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['fr', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}
