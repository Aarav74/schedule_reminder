import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class AppColors {
  // ============ MISSING BACKWARD COMPATIBLE COLORS ============
  static const Color textMuted = Color(0xFF6B6B7A);
  static const Color border = Color(0xFFE8E8F0);
  static const Color surfaceLight = Color(0xFFEEEEEE);

  // ============ PRIMARY COLORS ============
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color primaryContainer = Color(0xFFEDEBFF);
  
  // ============ SECONDARY COLORS ============
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF8BA3);
  static const Color secondaryDark = Color(0xFFE54A6A);
  static const Color secondaryContainer = Color(0xFFFFE8ED);
  
  // ============ BACKGROUND COLORS ============
  static const Color background = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF242438);
  
  // ============ STATUS COLORS ============
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFF69F0AE);
  static const Color successDark = Color(0xFF009624);
  static const Color successContainer = Color(0xFFE8F5E9);
  
  static const Color warning = Color(0xFFFFB300);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFC47F00);
  static const Color warningContainer = Color(0xFFFFF3E0);
  
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFB71C1C);
  static const Color errorContainer = Color(0xFFFFEBEE);
  
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1565C0);
  static const Color infoContainer = Color(0xFFE3F2FD);
  
  // ============ PRIORITY COLORS ============
  static const Color highPriority = Color(0xFFFF4757);
  static const Color highPriorityBg = Color(0xFFFFE8EA);
  static const Color mediumPriority = Color(0xFFFFB300);
  static const Color mediumPriorityBg = Color(0xFFFFF3E0);
  static const Color lowPriority = Color(0xFF00C853);
  static const Color lowPriorityBg = Color(0xFFE8F5E9);
  
  // ============ TEXT COLORS ============
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textPrimaryDark = Color(0xFFEAEAEA);
  static const Color textSecondary = Color(0xFF6B6B7A);
  static const Color textSecondaryDark = Color(0xFF9E9EAD);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFFE0E0E0);
  
  // ============ DIVIDER COLORS ============
  static const Color divider = Color(0xFFE8E8F0);
  static const Color dividerDark = Color(0xFF2D2D3F);
  
  // ============ SHADOW COLORS ============
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  
  // ============ GRADIENT COLORS ============
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, successDark],
  );
  
  static const LinearGradient priorityHighGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [highPriority, error],
  );
  
  static const LinearGradient priorityMediumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mediumPriority, warning],
  );
  
  static const LinearGradient priorityLowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lowPriority, success],
  );
  
  // ============ SPECIAL COLORS ============
  static const Color transparent = Colors.transparent;
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // ============ AI THEME COLORS ============
  static const Color aiGemini = Color(0xFF4285F4);
  static const Color aiOpenRouter = Color(0xFF6C63FF);
  static const Color aiProcessing = Color(0xFF7C4DFF);
  
  // ============ CALENDAR COLORS ============
  static const Color weekend = Color(0xFFFFEBEE);
  static const Color weekday = Color(0xFFF5F5F5);
  static const Color today = Color(0xFFE3F2FD);
  static const Color selected = Color(0xFF6C63FF);
  static const Color selectedText = Color(0xFFFFFFFF);
  
  // ============ METHOD TO GET COLOR BY PRIORITY ============
  static Color getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return highPriority;
      case Priority.medium:
        return mediumPriority;
      case Priority.low:
        return lowPriority;
    }
  }
  
  static Color getPriorityBackground(Priority priority) {
    switch (priority) {
      case Priority.high:
        return highPriorityBg;
      case Priority.medium:
        return mediumPriorityBg;
      case Priority.low:
        return lowPriorityBg;
    }
  }
  
  // ============ METHOD TO GET STATUS COLOR ============
  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return success;
      case TaskStatus.pending:
        return warning;
      case TaskStatus.missed:
        return error;
    }
  }
}