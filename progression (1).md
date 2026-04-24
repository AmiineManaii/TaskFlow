# 🚀 TaskFlow – Fichier de progression

> Deadline : **Vendredi 24/04/2026**  
> Architecture : **MVC** | État : **Riverpod** | BD : **SQLite + MockAPI**

---

## Avancement global

```
████████████████████████████░░░  ~85% COMPLÉTÉ ✅
```

---

## Phase 1 – Setup ⚙️ ✅ TERMINÉ
- [x] Structure dossiers MVC complète
- [x] pubspec.yaml avec toutes dépendances
- [x] l10n.yaml, app.dart, main.dart

## Phase 2 – Base de données 🗄️ ✅ TERMINÉ
- [x] database_helper.dart → SQLite singleton
- [x] Tables users, projects, tasks avec FK CASCADE
- [x] CRUD complet pour les 3 entités
- [x] api_service.dart → HTTP MockAPI (GET/POST/PUT/DELETE)
- [x] ⚠️ api_constants.dart → URL à remplir après création MockAPI

## Phase 3 – Modèles 📦 ✅ TERMINÉ
- [x] user_model.dart (fromMap, toMap, copyWith, initials)
- [x] project_model.dart (fromMap, toMap, copyWith, colorValue)
- [x] task_model.dart (enums, isOverdue, isSynced flag)

## Phase 4 – Controllers Riverpod 🎮 ✅ TERMINÉ
- [x] auth_controller.dart (login, register, logout, session persistante)
- [x] project_controller.dart (CRUD + sync API)
- [x] task_controller.dart (offline-first + syncPendingTasks)
- [x] theme_controller.dart + language_controller.dart

## Phase 5 – Auth 🔐 ✅ TERMINÉ
- [x] login_screen.dart + register_screen.dart
- [x] _AppGate → redirection auto si connecté

## Phase 6 – Projets 📁 ✅ TERMINÉ
- [x] home_screen.dart (BottomNav + onglet Projets)
- [x] project_detail_screen.dart (tabs + stats)
- [x] project_form_screen.dart (bottom sheet + sélecteur couleur)
- [x] project_card.dart (barre progression colorée)

## Phase 7 – Tâches ✅ ✅ TERMINÉ
- [x] task_form_screen.dart (priorité + assignée + date)
- [x] task_detail_screen.dart (statut inline + infos)
- [x] task_card.dart (checkbox rapide + badges + menu)
- [x] status_badge.dart + PriorityBadge

## Phase 8 – Collaboration 👥 ✅ TERMINÉ
- [x] Assignation dans task_form
- [x] my_tasks_screen.dart avec stats
- [x] user_avatar.dart (initiales colorées)

## Phase 9 – Notifications 🔔 ✅ TERMINÉ
- [x] notification_service.dart
- [x] Rappel 1h avant deadline
- [x] Alerte assignation

## Phase 10 – Mode sombre 🌙 ✅ TERMINÉ
- [x] app_theme.dart light + dark Material 3
- [x] Toggle dans Settings + persistance

## Phase 11 – Sync MockAPI 🔄 ✅ TERMINÉ
- [x] Offline-first avec isSynced flag
- [x] Sync auto + bouton manuel Settings
- [x] Indicateur orange sur TaskCard

## Phase 12 – i18n 🌍 ✅ TERMINÉ
- [x] app_fr.arb + app_en.arb (50+ clés chacun)
- [x] Sélecteur langue dans Settings

## Phase 13 – UI/UX ✨ ✅ TERMINÉ
- [x] Pull-to-refresh, empty states, loading states
- [x] Google Fonts Plus Jakarta Sans

## Phase 14 – Livrables 📦 - EN COURS
- [x] README.md complet
- [x] 30 fichiers Dart organisés MVC
- [ ] Captures d'écran ← après 1er lancement
- [ ] Build final flutter build apk --debug

---

## ⚠️ Actions à faire avant soumission

### 1. Configurer MockAPI (OBLIGATOIRE)
```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'https://TON_ID.mockapi.io/api/v1';
```

### 2. Commandes à lancer
```bash
flutter pub get
flutter gen-l10n    # génère les fichiers i18n
flutter run
```

### 3. AndroidManifest.xml – ajouter dans <manifest>
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

---

## Fichiers créés (30 fichiers Dart)

| Fichier | Statut |
|---|---|
| main.dart | ✅ |
| app.dart | ✅ |
| core/constants/api_constants.dart | ✅ ⚠️ configurer |
| core/constants/app_colors.dart | ✅ |
| core/database/database_helper.dart | ✅ |
| core/network/api_service.dart | ✅ |
| core/theme/app_theme.dart | ✅ |
| core/utils/date_utils.dart | ✅ |
| core/utils/notification_service.dart | ✅ |
| models/user_model.dart | ✅ |
| models/project_model.dart | ✅ |
| models/task_model.dart | ✅ |
| controllers/auth_controller.dart | ✅ |
| controllers/project_controller.dart | ✅ |
| controllers/task_controller.dart | ✅ |
| controllers/theme_controller.dart | ✅ |
| controllers/language_controller.dart | ✅ |
| views/auth/login_screen.dart | ✅ |
| views/auth/register_screen.dart | ✅ |
| views/home/home_screen.dart | ✅ |
| views/projects/project_detail_screen.dart | ✅ |
| views/projects/project_form_screen.dart | ✅ |
| views/tasks/task_form_screen.dart | ✅ |
| views/tasks/task_detail_screen.dart | ✅ |
| views/tasks/my_tasks_screen.dart | ✅ |
| views/settings/settings_screen.dart | ✅ |
| views/widgets/task_card.dart | ✅ |
| views/widgets/project_card.dart | ✅ |
| views/widgets/status_badge.dart | ✅ |
| views/widgets/user_avatar.dart | ✅ |
| l10n/app_fr.arb | ✅ |
| l10n/app_en.arb | ✅ |
| README.md | ✅ |
| pubspec.yaml | ✅ |
| l10n.yaml | ✅ |

---

## Récapitulatif des points

| Critère | Points | Statut |
|---|---|---|
| Fonctionnalités complètes | 8pts | ✅ |
| Architecture MVC | 4pts | ✅ |
| UI/UX Material 3 | 3pts | ✅ |
| Riverpod StateNotifier | 2pts | ✅ |
| Bonus (Notifs+Dark+Sync+i18n) | 3pts | ✅ |
| **TOTAL** | **~20pts** | ✅ |

_Dernière mise à jour : Session 2 – Projet quasi complet_
