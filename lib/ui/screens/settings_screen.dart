import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../providers/app_providers.dart';
import '../../core/constants.dart';
import '../../services/notifications_service.dart';
import '../../l10n/app_localizations.dart';
import 'login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del usuario
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.userInfo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(l10n.name),
                    subtitle: Text(user?.name ?? 'No disponible'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(l10n.email),
                    subtitle: Text(user?.email ?? 'No disponible'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(l10n.memberSince),
                    subtitle: Text(
                      user?.createdAt != null
                          ? _formatDate(user!.createdAt)
                          : 'No disponible',
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Configuraciones de la app
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appSettings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(l10n.notifications),
                    subtitle: const Text('Gestionar recordatorios'),
                    trailing: Switch(
                      value: true, // TODO: Conectar con provider
                      onChanged: (value) {
                        // TODO: Implementar toggle de notificaciones
                      },
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.notification_add),
                    title: Text(l10n.testNotification),
                    subtitle: const Text('Enviar notificación de prueba'),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _testNotification(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: Text(l10n.theme),
                    subtitle: Text(_getThemeSubtitle(ref)),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showThemeDialog(context, ref),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.language),
                    subtitle: Text(_getLanguageSubtitle(ref)),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showLanguageDialog(context, ref),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Categorías
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categorías de Tareas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...AppConstants.defaultCategories.map((category) {
                    return ListTile(
                      leading: const Icon(Icons.label),
                      title: Text(category),
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Implementar agregar categoría personalizada
                      _showAddCategoryDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Categoría'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información de la app
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Información',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Versión'),
                    subtitle: const Text('1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Ayuda y Soporte'),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      _showHelpDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Política de Privacidad'),
                    trailing: const Icon(Icons.chevron_right),
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      _showPrivacyDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón de cerrar sesión
          ElevatedButton.icon(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getThemeSubtitle(WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    return themeNotifier.getThemeLabel(themeMode);
  }

  String _getLanguageSubtitle(WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    return localeNotifier.getLanguageLabel(locale);
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.theme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            final isSelected = currentTheme == mode;
            return ListTile(
              leading: Icon(themeNotifier.getThemeIcon(mode)),
              title: Text(themeNotifier.getThemeLabel(mode)),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                themeNotifier.setTheme(mode);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: localeNotifier.supportedLocales.map((locale) {
            final isSelected = currentLocale == locale;
            return ListTile(
              leading: Text(localeNotifier.getLanguageFlag(locale)),
              title: Text(localeNotifier.getLanguageLabel(locale)),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                localeNotifier.setLocale(locale);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            hintText: 'Ej: Deportes, Finanzas...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                // TODO: Implementar agregar categoría
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función próximamente disponible'),
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda y Soporte'),
        content: const Text(
          'Productividad App te ayuda a organizar tus tareas diarias.\n\n'
          'Características principales:\n'
          '• Crear y gestionar tareas\n'
          '• Establecer prioridades\n'
          '• Configurar recordatorios\n'
          '• Filtrar por estado\n'
          '• Organizar por categorías\n\n'
          'Para soporte técnico, contacta: soporte@productividadapp.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'Política de Privacidad - Productividad App\n\n'
            '1. Información que recopilamos:\n'
            '• Datos de registro (nombre, email)\n'
            '• Tareas y recordatorios que creas\n'
            '• Preferencias de configuración\n\n'
            '2. Uso de la información:\n'
            '• Proporcionar funcionalidad de la app\n'
            '• Mejorar la experiencia del usuario\n'
            '• Enviar recordatorios configurados\n\n'
            '3. Almacenamiento:\n'
            '• Los datos se almacenan localmente en tu dispositivo\n'
            '• No compartimos información con terceros\n'
            '• Puedes eliminar tus datos en cualquier momento\n\n'
            'Última actualización: Enero 2024',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _testNotification(BuildContext context) async {
    try {
      final notificationService = NotificationsService();
      
      await notificationService.showNotification(
        id: 999,
        title: '🎉 Notificación de Prueba',
        body: 'Las notificaciones están funcionando correctamente!',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación enviada! Revisa tu navegador/dispositivo'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error enviando notificación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              
              ref.read(currentUserProvider.notifier).clearUser();
              ref.read(authStateProvider.notifier).setAuthenticated(false);
              
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}