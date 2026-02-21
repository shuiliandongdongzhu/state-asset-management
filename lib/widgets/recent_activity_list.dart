import 'package:flutter/material.dart';

class RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('暂无活动记录'),
        ),
      );
    }

    return Column(
      children: activities.map((activity) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: (activity['color'] as Color? ?? Colors.blue).withOpacity(0.1),
            child: Icon(
              activity['icon'] as IconData? ?? Icons.info,
              color: activity['color'] as Color? ?? Colors.blue,
              size: 20,
            ),
          ),
          title: Text(activity['title'] as String? ?? ''),
          subtitle: Text(activity['subtitle'] as String? ?? ''),
          trailing: Text(
            activity['time'] as String? ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }).toList(),
    );
  }
}
