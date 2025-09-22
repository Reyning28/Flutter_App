import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
  ];



  String get appTitle => locale.languageCode == 'es' ? 'Productividad App' : 'Productivity App';
  String get settings => locale.languageCode == 'es' ? 'Configuraciones' : 'Settings';
  String get userInfo => locale.languageCode == 'es' ? 'Información del Usuario' : 'User Information';
  String get name => locale.languageCode == 'es' ? 'Nombre' : 'Name';
  String get email => locale.languageCode == 'es' ? 'Email' : 'Email';
  String get memberSince => locale.languageCode == 'es' ? 'Miembro desde' : 'Member since';
  String get appSettings => locale.languageCode == 'es' ? 'Configuraciones de la App' : 'App Settings';
  String get notifications => locale.languageCode == 'es' ? 'Notificaciones' : 'Notifications';
  String get testNotification => locale.languageCode == 'es' ? 'Probar Notificación' : 'Test Notification';
  String get theme => locale.languageCode == 'es' ? 'Tema' : 'Theme';
  String get language => locale.languageCode == 'es' ? 'Idioma' : 'Language';
  String get taskCategories => locale.languageCode == 'es' ? 'Categorías de Tareas' : 'Task Categories';
  String get addCategory => locale.languageCode == 'es' ? 'Agregar Categoría' : 'Add Category';
  String get information => locale.languageCode == 'es' ? 'Información' : 'Information';
  String get version => locale.languageCode == 'es' ? 'Versión' : 'Version';
  String get helpSupport => locale.languageCode == 'es' ? 'Ayuda y Soporte' : 'Help & Support';
  String get privacyPolicy => locale.languageCode == 'es' ? 'Política de Privacidad' : 'Privacy Policy';
  String get logout => locale.languageCode == 'es' ? 'Cerrar Sesión' : 'Logout';
  String get close => locale.languageCode == 'es' ? 'Cerrar' : 'Close';
  String get understood => locale.languageCode == 'es' ? 'Entendido' : 'Understood';
  String get cancel => locale.languageCode == 'es' ? 'Cancelar' : 'Cancel';
  
  // Temas
  String get automatic => locale.languageCode == 'es' ? 'Automático' : 'Automatic';
  String get light => locale.languageCode == 'es' ? 'Claro' : 'Light';
  String get dark => locale.languageCode == 'es' ? 'Oscuro' : 'Dark';
  
  // Idiomas
  String get spanish => locale.languageCode == 'es' ? 'Español' : 'Spanish';
  String get english => locale.languageCode == 'es' ? 'English' : 'English';
  
  // Tareas
  String get tasks => locale.languageCode == 'es' ? 'Tareas' : 'Tasks';
  String get allTasks => locale.languageCode == 'es' ? 'Todas' : 'All';
  String get pendingTasks => locale.languageCode == 'es' ? 'Pendientes' : 'Pending';
  String get completedTasks => locale.languageCode == 'es' ? 'Completadas' : 'Completed';
  String get overdueTasks => locale.languageCode == 'es' ? 'Vencidas' : 'Overdue';
  String get todayTasks => locale.languageCode == 'es' ? 'Hoy' : 'Today';
  String get total => locale.languageCode == 'es' ? 'Total' : 'Total';
  String get pending => locale.languageCode == 'es' ? 'Pendientes' : 'Pending';
  String get completed => locale.languageCode == 'es' ? 'Completadas' : 'Completed';
  String get overdue => locale.languageCode == 'es' ? 'Vencidas' : 'Overdue';
  String get newTask => locale.languageCode == 'es' ? 'Nueva Tarea' : 'New Task';
  String get editTask => locale.languageCode == 'es' ? 'Editar Tarea' : 'Edit Task';
  String get search => locale.languageCode == 'es' ? 'Buscar' : 'Search';
  String get searchTasks => locale.languageCode == 'es' ? 'Buscar tareas...' : 'Search tasks...';
  String get noTasks => locale.languageCode == 'es' ? 'No hay tareas' : 'No tasks';
  String get noResults => locale.languageCode == 'es' ? 'Sin resultados' : 'No results';
  String get createTask => locale.languageCode == 'es' ? 'Crear Tarea' : 'Create Task';
  String get clearSearch => locale.languageCode == 'es' ? 'Limpiar Búsqueda' : 'Clear Search';
  
  String hello(String name) => locale.languageCode == 'es' ? 'Hola, $name' : 'Hello, $name';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}