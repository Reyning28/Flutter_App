import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar base de datos para web
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }
  
  // Inicializar servicio de notificaciones
  try {
    await NotificationsService().initialize();
    print('Servicio de notificaciones inicializado');
  } catch (e) {
    print('Error inicializando notificaciones: $e');
  }
  
  runApp(const ProviderScope(child: ProductivityApp()));
}
