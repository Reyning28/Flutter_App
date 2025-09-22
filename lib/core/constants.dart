class AppConstants {
  // Database
  static const String databaseName = 'productivity_app.db';
  static const int databaseVersion = 1;
  
  // Tables
  static const String usersTable = 'users';
  static const String tasksTable = 'tasks';
  static const String categoriesTable = 'categories';
  
  // Task Status
  static const String taskStatusPending = 'pending';
  static const String taskStatusCompleted = 'completed';
  
  // Task Priority
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  
  // Default Categories
  static const List<String> defaultCategories = [
    'Trabajo',
    'Personal',
    'Estudios',
    'Salud',
    'Hogar',
  ];
  
  // Notification
  static const String notificationChannelId = 'task_reminders';
  static const String notificationChannelName = 'Recordatorios de Tareas';
  static const String notificationChannelDescription = 'Notificaciones para recordatorios de tareas';
  
  // SharedPreferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  
  // Languages
  static const String languageSpanish = 'es';
  static const String languageEnglish = 'en';
}