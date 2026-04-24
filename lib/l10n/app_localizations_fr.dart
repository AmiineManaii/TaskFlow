// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TaskFlow';

  @override
  String get login => 'Connexion';

  @override
  String get register => 'Inscription';

  @override
  String get logout => 'Déconnexion';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get name => 'Nom complet';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get noAccount => 'Pas encore de compte ?';

  @override
  String get alreadyAccount => 'Déjà un compte ?';

  @override
  String get loginError => 'Email ou mot de passe incorrect';

  @override
  String get registerError => 'Erreur lors de l\'inscription';

  @override
  String get emailInvalid => 'Email invalide';

  @override
  String get passwordShort => 'Mot de passe trop court (6 caractères min)';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get projects => 'Projets';

  @override
  String get myProjects => 'Mes projets';

  @override
  String get addProject => 'Nouveau projet';

  @override
  String get editProject => 'Modifier le projet';

  @override
  String get deleteProject => 'Supprimer le projet';

  @override
  String get deleteProjectConfirm =>
      'Supprimer ce projet et toutes ses tâches ?';

  @override
  String get projectName => 'Nom du projet';

  @override
  String get projectDescription => 'Description';

  @override
  String get projectColor => 'Couleur';

  @override
  String get noProjects => 'Aucun projet pour l\'instant';

  @override
  String get createFirstProject => 'Créez votre premier projet';

  @override
  String get tasks => 'Tâches';

  @override
  String get myTasks => 'Mes tâches';

  @override
  String get addTask => 'Nouvelle tâche';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get deleteTask => 'Supprimer la tâche';

  @override
  String get deleteTaskConfirm => 'Supprimer cette tâche ?';

  @override
  String get taskTitle => 'Titre de la tâche';

  @override
  String get taskDescription => 'Description';

  @override
  String get noTasks => 'Aucune tâche dans ce projet';

  @override
  String get addFirstTask => 'Ajoutez votre première tâche';

  @override
  String get status => 'Statut';

  @override
  String get status_todo => 'À faire';

  @override
  String get status_inProgress => 'En cours';

  @override
  String get status_done => 'Terminé';

  @override
  String get priority => 'Priorité';

  @override
  String get priority_low => 'Faible';

  @override
  String get priority_medium => 'Moyenne';

  @override
  String get priority_high => 'Haute';

  @override
  String get assignTo => 'Assigner à';

  @override
  String get assignee => 'Assigné à';

  @override
  String get unassigned => 'Non assigné';

  @override
  String get dueDate => 'Date limite';

  @override
  String get noDueDate => 'Pas de date limite';

  @override
  String get createdAt => 'Créé le';

  @override
  String get overdue => 'En retard';

  @override
  String get delete => 'Supprimer';

  @override
  String get hello => 'Bonjour';

  @override
  String get error => 'Erreur';

  @override
  String get syncing => 'Synchronisation en cours...';

  @override
  String get newProject => 'Nouveau projet';

  @override
  String get all => 'Tout';

  @override
  String get total => 'Total';

  @override
  String get settings => 'Paramètres';

  @override
  String get appearance => 'Apparence';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get language => 'Langue';

  @override
  String get data => 'Données';

  @override
  String get syncWithServer => 'Synchroniser avec le serveur';

  @override
  String get syncSubtitle => 'Envoyer les données en attente';

  @override
  String get localData => 'Données locales';

  @override
  String get sqliteActive => 'SQLite actif';

  @override
  String get account => 'Compte';

  @override
  String get logoutConfirm => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get loading => 'Chargement...';

  @override
  String get syncInProgress => 'Synchronisation en cours...';

  @override
  String get syncSuccess => 'Synchronisation réussie';

  @override
  String get syncError => 'Erreur de synchronisation';

  @override
  String get noUsersAvailable => 'Aucun utilisateur disponible';

  @override
  String get noDateSet => 'Aucune date définie';

  @override
  String get update => 'Mettre à jour';

  @override
  String get create => 'Créer';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get users => 'Utilisateurs';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get sync => 'Synchroniser';

  @override
  String get pendingSync => 'tâche(s) en attente de sync';

  @override
  String get offline => 'Hors ligne';

  @override
  String get online => 'En ligne';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get notificationTaskDue => 'Tâche bientôt due';

  @override
  String get notificationAssigned => 'Nouvelle tâche assignée';

  @override
  String get done => 'Terminées';

  @override
  String get inProgress => 'En cours';

  @override
  String get todo => 'À faire';

  @override
  String get clearLocalData => 'Supprimer les données locales';

  @override
  String get clearLocalDataSubtitle => 'Utilisateurs, projets et tâches';

  @override
  String get clearLocalDataConfirm =>
      'Que voulez-vous supprimer de la base locale ?';

  @override
  String get clearLocalDataSuccess => 'Données locales supprimées avec succès';

  @override
  String get clearAll => 'Tout supprimer';
}
