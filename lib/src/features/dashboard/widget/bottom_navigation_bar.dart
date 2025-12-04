import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/dashboard/logic/navigation_bar_item.dart';
import 'package:myapp/src/features/dashboard/logic/dashboard_bloc.dart';

class XBottomNavigationBar extends StatelessWidget {
  const XBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, XNavigationBarItems>(
      builder: (context, state) {
        return NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          selectedIndex: state.index,
          onDestinationSelected:
              context.read<DashboardBloc>().onDestinationSelected,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: XNavigationBarItems.values
              .map(
                (e) => NavigationDestination(
                  label: e.getLabel(context),
                  icon: Icon(e.icon,
                      color: state == e
                          ? const Color(0xFF6C63FF)
                          : Colors.grey[400]),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
