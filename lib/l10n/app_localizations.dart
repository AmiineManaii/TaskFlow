import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The application title
  ///
  /// In fr, this message translates to:
  /// **'TaskFlow'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @name.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get name;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de compte ?'**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ?'**
  String get alreadyAccount;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Email ou mot de passe incorrect'**
  String get loginError;

  /// No description provided for @registerError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'inscription'**
  String get registerError;

  /// No description provided for @emailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get emailInvalid;

  /// No description provided for @passwordShort.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop court (6 caractères min)'**
  String get passwordShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordMismatch;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire'**
  String get fieldRequired;

  /// No description provided for @projects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get projects;

  /// No description provided for @myProjects.
  ///
  /// In fr, this message translates to:
  /// **'Mes projets'**
  String get myProjects;

  /// No description provided for @addProject.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau projet'**
  String get addProject;

  /// No description provided for @editProject.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le projet'**
  String get editProject;

  /// No description provided for @deleteProject.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le projet'**
  String get deleteProject;

  /// No description provided for @deleteProjectConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce projet et toutes ses tâches ?'**
  String get deleteProjectConfirm;

  /// No description provided for @projectName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du projet'**
  String get projectName;

  /// No description provided for @projectDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get projectDescription;

  /// No description provided for @projectColor.
  ///
  /// In fr, this message translates to:
  /// **'Couleur'**
  String get projectColor;

  /// No description provided for @noProjects.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet pour l\'instant'**
  String get noProjects;

  /// No description provided for @createFirstProject.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre premier projet'**
  String get createFirstProject;

  /// No description provided for @tasks.
  ///
  /// In fr, this message translates to:
  /// **'Tâches'**
  String get tasks;

  /// No description provided for @myTasks.
  ///
  /// In fr, this message translates to:
  /// **'Mes tâches'**
  String get myTasks;

  /// No description provided for @addTask.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la tâche'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la tâche'**
  String get deleteTask;

  /// No description provided for @deleteTaskConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette tâche ?'**
  String get deleteTaskConfirm;

  /// No description provided for @taskTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre de la tâche'**
  String get taskTitle;

  /// No description provided for @taskDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get taskDescription;

  /// No description provided for @noTasks.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche dans ce projet'**
  String get noTasks;

  /// No description provided for @addFirstTask.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre première tâche'**
  String get addFirstTask;

  /// No description provided for @status.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get status;

  /// No description provided for @status_todo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get status_todo;

  /// No description provided for @status_inProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get status_inProgress;

  /// No description provided for @status_done.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get status_done;

  /// No description provided for @priority.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get priority;

  /// No description provided for @priority_low.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get priority_low;

  /// No description provided for @priority_medium.
  ///
  /// In fr, this message translates to:
  /// **'Moyenne'**
  String get priority_medium;

  /// No description provided for @priority_high.
  ///
  /// In fr, this message translates to:
  /// **'Haute'**
  String get priority_high;

  /// No description provided for @assignTo.
  ///
  /// In fr, this message translates to:
  /// **'Assigner à'**
  String get assignTo;

  /// No description provided for @assignee.
  ///
  /// In fr, this message translates to:
  /// **'Assigné à'**
  String get assignee;

  /// No description provided for @unassigned.
  ///
  /// In fr, this message translates to:
  /// **'Non assigné'**
  String get unassigned;

  /// No description provided for @dueDate.
  ///
  /// In fr, this message translates to:
  /// **'Date limite'**
  String get dueDate;

  /// No description provided for @noDueDate.
  ///
  /// In fr, this message translates to:
  /// **'Pas de date limite'**
  String get noDueDate;

  /// No description provided for @createdAt.
  ///
  /// In fr, this message translates to:
  /// **'Créé le'**
  String get createdAt;

  /// No description provided for @overdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get overdue;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @hello.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get hello;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @syncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours...'**
  String get syncing;

  /// No description provided for @newProject.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau projet'**
  String get newProject;

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get all;

  /// No description provided for @total.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @enabled.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get disabled;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @data.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get data;

  /// No description provided for @syncWithServer.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser avec le serveur'**
  String get syncWithServer;

  /// No description provided for @syncSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer les données en attente'**
  String get syncSubtitle;

  /// No description provided for @localData.
  ///
  /// In fr, this message translates to:
  /// **'Données locales'**
  String get localData;

  /// No description provided for @sqliteActive.
  ///
  /// In fr, this message translates to:
  /// **'SQLite actif'**
  String get sqliteActive;

  /// No description provided for @account.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get account;

  /// No description provided for @logoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment vous déconnecter ?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @syncInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours...'**
  String get syncInProgress;

  /// No description provided for @syncSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation réussie'**
  String get syncSuccess;

  /// No description provided for @syncError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchronisation'**
  String get syncError;

  /// No description provided for @noUsersAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur disponible'**
  String get noUsersAvailable;

  /// No description provided for @noDateSet.
  ///
  /// In fr, this message translates to:
  /// **'Aucune date définie'**
  String get noDateSet;

  /// No description provided for @update.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get update;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @users.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get users;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sync.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get sync;

  /// No description provided for @pendingSync.
  ///
  /// In fr, this message translates to:
  /// **'tâche(s) en attente de sync'**
  String get pendingSync;

  /// No description provided for @offline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get offline;

  /// No description provided for @online.
  ///
  /// In fr, this message translates to:
  /// **'En ligne'**
  String get online;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @notificationTaskDue.
  ///
  /// In fr, this message translates to:
  /// **'Tâche bientôt due'**
  String get notificationTaskDue;

  /// No description provided for @notificationAssigned.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle tâche assignée'**
  String get notificationAssigned;

  /// No description provided for @done.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get done;

  /// No description provided for @inProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgress;

  /// No description provided for @todo.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get todo;

  /// No description provided for @clearLocalData.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les données locales'**
  String get clearLocalData;

  /// No description provided for @clearLocalDataSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs, projets et tâches'**
  String get clearLocalDataSubtitle;

  /// No description provided for @clearLocalDataConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Que voulez-vous supprimer de la base locale ?'**
  String get clearLocalDataConfirm;

  /// No description provided for @clearLocalDataSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Données locales supprimées avec succès'**
  String get clearLocalDataSuccess;

  /// No description provided for @clearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get clearAll;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
