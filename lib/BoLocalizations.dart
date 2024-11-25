import 'package:flutter/material.dart';

class BoLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const BoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'bo' || locale.languageCode == 'mai' || locale.languageCode == 'mni';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return MaterialLocalizationsDelegate().load(locale);
  }

  @override
  bool shouldReload(BoLocalizationsDelegate old) => false;
}

class MaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const MaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'bo' || locale.languageCode == 'mai' || locale.languageCode == 'mni';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return DefaultMaterialLocalizations();
  }

  @override
  bool shouldReload(MaterialLocalizationsDelegate old) => false;
}
