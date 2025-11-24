# Guide de Localisation et Internationalisation (Nationalisation) Flutter

Ce document explique comment implémenter la localisation (changement de langues) dans les applications Flutter, permettant aux utilisateurs de changer de langue dynamiquement.

---

## 1. Introduction

La localisation permet à votre application de supporter plusieurs langues et régions. Flutter offre un système de localisation robuste intégré avec le package `intl` et supporte le changement automatique de locale, le formatage et les traductions.

---

## 2. Concepts Clés

- **Locale** : Représente la langue et la région d'un utilisateur (ex. `en_US`, `fr_FR`).
- **Délégué de Localisation** : Charge les ressources localisées en fonction de la locale actuelle.
- **Fichiers ARB** : Fichiers de type JSON (`app_en.arb`, `app_fr.arb`) contenant les chaînes traduites.
- **Package `intl`** : Fournit des utilitaires d'internationalisation utilisés par l'outil gen_l10n de Flutter.

---

## 3. Configuration de la Localisation dans Flutter

### 3.1 Ajouter le Support de Localisation Flutter

Dans votre `pubspec.yaml`, assurez-vous d'avoir :

```yaml
flutter:
  generate: true
  # Autre config ...
```

Cela active la génération de code de localisation de Flutter.

### 3.2 Créer des Fichiers ARB

Créez des fichiers comme `lib/src/localization/app_en.arb` et `lib/src/localization/app_fr.arb`. Contenu d'exemple :

```json
// app_en.arb
{
  "@@locale": "en",
  "welcome": "Welcome",
  "darkMode": "Dark Mode",
  "logout": "Logout"
}

// app_fr.arb
{
  "@@locale": "fr",
  "welcome": "Bienvenue",
  "darkMode": "Mode Sombre",
  "logout": "Déconnexion"
}
```

### 3.3 Configurer les Classes de Localisation

Flutter génère automatiquement une classe de localisation (`AppLocalizations`) à partir des fichiers ARB après la construction.

Importez avec :
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

Utilisez les chaînes comme :
```dart
Text(AppLocalizations.of(context)!.welcome);
```

---

## 4. Implémenter la Gestion de Locale dans l'Application

### 4.1 Exemple de LocaleProvider

Créez un Provider (`lib/src/localization/locale_provider.dart`) pour gérer la locale sélectionnée :

```dart
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
```

### 4.2 Utiliser le Provider dans l'Application Principale

Enveloppez l'application dans ChangeNotifierProvider dans `main.dart` :

```dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: provider.locale,
      // ...
    );
  }
}
```

### 4.3 Changer de Langue à l'Exécution

Dans n'importe quel widget, utilisez le provider pour changer de langue :

```dart
final provider = Provider.of<LocaleProvider>(context, listen: false);
provider.setLocale(const Locale('en'));
```

---

## 5. Exemple d'Utilisation dans un Widget

```dart
ListTile(
  leading: Icon(Icons.language),
  title: Text(Localizations.localeOf(context).languageCode == 'fr' ? 'Français' : 'English'),
  trailing: Icon(Icons.arrow_drop_down),
  onTap: () {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    provider.setLocale(Locale(isFrench ? 'en' : 'fr'));
  },
)
```

---

## 6. Considérations Supplémentaires

- Toujours fournir une locale de secours.
- Tester sur les changements de locale de l'appareil.
- Utiliser le package `intl` pour le formatage des dates, nombres.
- Maintenir les fichiers ARB avec des clés cohérentes.
- Régénérer les fichiers de localisation après mise à jour des fichiers ARB (`flutter pub get` ou lors de la construction).

---

## 7. Références

- [Documentation Internationalisation Flutter](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [Package intl](https://pub.dev/packages/intl)
- Outil Flutter Gen L10n pour la génération automatique de code de localisation.

---

Cette documentation résume les étapes pour implémenter la localisation (nationalisation) dans votre application Flutter permettant le changement dynamique de langue.

Pour plus d'aide ou d'exemples, n'hésitez pas à demander.
