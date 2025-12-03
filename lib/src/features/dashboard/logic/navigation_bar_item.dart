import 'package:flutter/material.dart';
import 'package:myapp/src/router/route_name.dart';

enum XNavigationBarItems {
  photos(
    label: 'Ảnh',
    route: AppRouteNames.photo,
    icon: Icons.photo_library_outlined,
    selectedIcon: Icons.photo_library,
  ),
  cleaner(
    label: 'Dọn dẹp',
    route: AppRouteNames.cleaner,
    icon: Icons.cleaning_services_outlined,
    selectedIcon: Icons.cleaning_services,
  ),
  friend(
    label: 'Bạn bè',
    route: AppRouteNames.friend,
    icon: Icons.group_outlined,
    selectedIcon: Icons.group,
  ),
  places(
    label: 'Địa điểm',
    route: AppRouteNames.places,
    icon: Icons.map_outlined,
    selectedIcon: Icons.map,
  ),
  profile(
    label: 'Hồ sơ',
    route: AppRouteNames.profile,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  );

  const XNavigationBarItems({
    required this.label,
    required this.route,
    required this.icon,
    this.selectedIcon,
  });

  final String label;
  final AppRouteNames route;
  final IconData icon;
  final IconData? selectedIcon;

  static XNavigationBarItems fromLocation(String location) {
    if (location.startsWith(XNavigationBarItems.photos.route.path)) {
      return XNavigationBarItems.photos;
    } else if (location.startsWith(XNavigationBarItems.cleaner.route.path)) {
      return XNavigationBarItems.cleaner;
    } else if (location.startsWith(XNavigationBarItems.friend.route.path)) {
      return XNavigationBarItems.friend;
    } else if (location.startsWith(XNavigationBarItems.places.route.path)) {
      return XNavigationBarItems.places;
    } else if (location.startsWith(XNavigationBarItems.profile.route.path)) {
      return XNavigationBarItems.profile;
    }
    return XNavigationBarItems.photos;
  }
}
