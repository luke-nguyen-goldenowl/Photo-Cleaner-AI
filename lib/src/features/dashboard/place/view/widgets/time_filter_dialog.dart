import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/dashboard/place/view/widgets/custom_time_range.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import '../../logic/place_bloc.dart';

class XTimeFilterDialog extends StatelessWidget {
  const XTimeFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).common_filter_by_time),
      content: BlocBuilder<PlaceBloc, PlaceState>(
        buildWhen: (previous, current) {
          return previous.timeFilter != current.timeFilter ||
              previous.customRange != current.customRange;
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(
                context,
                currentFilter: state.timeFilter,
                filter: TimeFilter.all,
                label: S.of(context).common_filter_all,
                icon: Icons.all_inclusive,
              ),
              _buildFilterOption(
                context,
                currentFilter: state.timeFilter,
                filter: TimeFilter.today,
                label: S.of(context).common_filter_today,
                icon: Icons.today,
              ),
              _buildFilterOption(
                context,
                currentFilter: state.timeFilter,
                filter: TimeFilter.thisWeek,
                label: S.of(context).common_filter_week,
                icon: Icons.date_range,
              ),
              _buildFilterOption(
                context,
                currentFilter: state.timeFilter,
                filter: TimeFilter.thisMonth,
                label: S.of(context).common_filter_month,
                icon: Icons.calendar_month,
              ),
              _buildFilterOption(
                context,
                currentFilter: state.timeFilter,
                filter: TimeFilter.thisYear,
                label: S.of(context).common_filter_year,
                icon: Icons.calendar_today,
              ),
              _buildFilterOption(
                context,
                currentFilter: state.timeFilter,
                filter: TimeFilter.custom,
                label: S.of(context).common_filter_custom,
                icon: Icons.av_timer_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}

Widget _buildFilterOption(BuildContext context,
    {required TimeFilter currentFilter,
    required TimeFilter filter,
    required String label,
    required IconData icon}) {
  final isSelected = currentFilter == filter;
  return ListTile(
    leading: Icon(
      icon,
      color: isSelected ? Colors.blue[700] : Colors.grey[600],
    ),
    title: Text(
      label,
      style: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.blue[700] : Colors.grey[800],
      ),
    ),
    trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
    onTap: () {
      if (filter == TimeFilter.custom) {
        final state = context.read<PlaceBloc>().state;
        final bloc = context.read<PlaceBloc>();
        showDialog(
          context: context,
          builder: (context) => XCustomDateRangeDialog(
            initialRange: state.customRange,
            onConfirmed: (selectedRange) {
              bloc.setTimeFilter(filter, customRange: selectedRange);
              Navigator.pop(context);
            },
          ),
        );
        return;
      }
      context.read<PlaceBloc>().setTimeFilter(filter);
      Navigator.pop(context);
    },
  );
}
