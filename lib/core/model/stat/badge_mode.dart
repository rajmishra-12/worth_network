
import 'package:worth_network/core/constants/app_images.dart';

class BadgeConfig {
  final int days;
  final String title;
  final String image;

  const BadgeConfig(this.days, this.title, this.image);
}

const badgeConfigs = [
  BadgeConfig(1, "First step", AppImages.badge1),
  BadgeConfig(3, "You’re holding on", AppImages.badge3),
  BadgeConfig(7, "One week", AppImages.badge7),
  BadgeConfig(30, "Transformation", AppImages.badge30),
  BadgeConfig(90, "Rebirth", AppImages.badge90),
];
