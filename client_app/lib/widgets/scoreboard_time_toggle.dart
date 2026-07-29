import 'package:flutter/material.dart';

class ScoreboardTimeToggle extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const ScoreboardTimeToggle({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All Time')),
              ButtonSegment(value: 'month', label: Text('This Month')),
              ButtonSegment(value: 'week', label: Text('This Week')),
            ],
            selected: {selectedFilter},
            onSelectionChanged: (Set<String> newSelection) {
              onFilterChanged(newSelection.first);
            },
          ),
        ),
      ),
    );
  }
}
