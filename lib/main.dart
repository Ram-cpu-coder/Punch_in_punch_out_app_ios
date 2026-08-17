import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'core/api_client.dart';
part 'models/time_models.dart';
part 'utils/time_utils.dart';
part 'widgets/clock_widgets.dart';
part 'widgets/common_widgets.dart';
part 'widgets/records_widgets.dart';
part 'widgets/work_widgets.dart';
part 'widgets/legacy_record_widgets.dart';
part 'screens/app_shell.dart';

const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:5000',
);

const sessionTokenKey = 'punchin_access_token';
const sessionUserKey = 'punchin_user';

void main() {
  runApp(const PunchInApp());
}

class PunchInApp extends StatelessWidget {
  const PunchInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punch In',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff1d6f68),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AppShell(),
    );
  }
}
