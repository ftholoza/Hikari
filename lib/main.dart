import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'app.dart';
import 'pages/calendar/data/planning_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PlanningRepository.loadEntries();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  runZonedGuarded(() {
    runApp(const HikariApp());
  }, (error, stackTrace) {
    debugPrint('ZONE ERROR: $error');
    debugPrint('$stackTrace');
  });
}