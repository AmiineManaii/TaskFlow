import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await NotificationService.init();
  await NotificationService.requestPermissions();

  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}
