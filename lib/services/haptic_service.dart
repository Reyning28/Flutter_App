import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  // Feedback ligero para interacciones básicas
  static Future<void> lightImpact() async {
    if (kIsWeb) return; // No vibración en web
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      print('Error con haptic feedback: $e');
    }
  }

  // Feedback medio para acciones importantes
  static Future<void> mediumImpact() async {
    if (kIsWeb) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      print('Error con haptic feedback: $e');
    }
  }

  // Feedback fuerte para acciones críticas
  static Future<void> heavyImpact() async {
    if (kIsWeb) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('Error con haptic feedback: $e');
    }
  }

  // Feedback de selección
  static Future<void> selectionClick() async {
    if (kIsWeb) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      print('Error con haptic feedback: $e');
    }
  }

  // Vibración personalizada para completar tarea
  static Future<void> taskCompleted() async {
    if (kIsWeb) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 100);
        await Future.delayed(const Duration(milliseconds: 50));
        await Vibration.vibrate(duration: 50);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      print('Error con vibración: $e');
    }
  }

  // Vibración para notificación
  static Future<void> notification() async {
    if (kIsWeb) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 200);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      print('Error con vibración: $e');
    }
  }

  // Vibración de error
  static Future<void> error() async {
    if (kIsWeb) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 100);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 100);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 100);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      print('Error con vibración: $e');
    }
  }

  // Vibración de éxito
  static Future<void> success() async {
    if (kIsWeb) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 50);
        await Future.delayed(const Duration(milliseconds: 50));
        await Vibration.vibrate(duration: 100);
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      print('Error con vibración: $e');
    }
  }
}