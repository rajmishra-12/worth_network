import 'package:flutter/material.dart';
import 'package:worth_network/core/utils/app_localizations.dart';

class AccountTypeOption {
  final String key;
  final String label;
  final IconData icon;

  const AccountTypeOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  String getLocalizedLabel(AppLocalizations loc) {
    final locKey = 'account_type_$key';
    final translated = loc.translate(locKey);
    return translated != locKey ? translated : label;
  }
}

class RoleOption {
  final String key;
  final String label;
  final IconData icon;

  const RoleOption({
    required this.key,
    required this.label,
    required this.icon,
  });

  String getLocalizedLabel(AppLocalizations loc) {
    final locKey = 'role_$key';
    final translated = loc.translate(locKey);
    return translated != locKey ? translated : label;
  }
}

class ProfileConstants {
  static const List<AccountTypeOption> accountTypes = [
    AccountTypeOption(key: 'particular', label: 'Particular', icon: Icons.person_outline),
    AccountTypeOption(key: 'association', label: 'Association', icon: Icons.groups_outlined),
    AccountTypeOption(key: 'business', label: 'Business', icon: Icons.business_outlined),
    AccountTypeOption(key: 'foundation', label: 'Foundation / NGO', icon: Icons.volunteer_activism_outlined),
    AccountTypeOption(key: 'institution', label: 'Institution / Community', icon: Icons.location_city_outlined),
    AccountTypeOption(key: 'public_service', label: 'Public Establishment / Service', icon: Icons.account_balance_outlined),
    AccountTypeOption(key: 'other', label: 'Other', icon: Icons.more_horiz_outlined),
  ];

  static const List<RoleOption> roles = [
    RoleOption(key: 'volunteer', label: 'Volunteer', icon: Icons.handshake_outlined),
    RoleOption(key: 'healthcare', label: 'Healthcare professional', icon: Icons.local_hospital_outlined),
    RoleOption(key: 'first_aider', label: 'First aider', icon: Icons.medical_services_outlined),
    RoleOption(key: 'firefighter', label: 'Firefighter', icon: Icons.local_fire_department_outlined),
    RoleOption(key: 'teacher', label: 'Teacher / Educator', icon: Icons.school_outlined),
    RoleOption(key: 'caregiver', label: 'Caregiver', icon: Icons.favorite_outline),
    RoleOption(key: 'entrepreneur', label: 'Entrepreneur', icon: Icons.lightbulb_outline),
    RoleOption(key: 'artisan', label: 'Artisan', icon: Icons.build_outlined),
    RoleOption(key: 'sporty', label: 'Sporty', icon: Icons.fitness_center_outlined),
    RoleOption(key: 'student', label: 'Student', icon: Icons.menu_book_outlined),
    RoleOption(key: 'content_creator', label: 'Content creator', icon: Icons.video_camera_back_outlined),
    RoleOption(key: 'other', label: 'Other', icon: Icons.more_horiz_outlined),
  ];

  static AccountTypeOption? getAccountType(String? key) {
    if (key == null || key.isEmpty) return null;
    try {
      return accountTypes.firstWhere(
        (e) => e.key.toLowerCase() == key.toLowerCase() || e.label.toLowerCase() == key.toLowerCase(),
      );
    } catch (_) {
      return AccountTypeOption(key: key, label: key, icon: Icons.person_outline);
    }
  }

  static RoleOption getRole(String key) {
    try {
      return roles.firstWhere(
        (e) => e.key.toLowerCase() == key.toLowerCase() || e.label.toLowerCase() == key.toLowerCase(),
      );
    } catch (_) {
      return RoleOption(key: key, label: key, icon: Icons.workspace_premium_outlined);
    }
  }
}

