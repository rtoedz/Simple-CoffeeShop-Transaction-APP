import 'package:flutter/material.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';

class SalesChart extends StatelessWidget {
  final List<WeeklyData> data;
  final double maxHeight;

  const SalesChart({
    super.key,
    required this.data,
    this.maxHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: maxHeight,
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final maxSales = data.isEmpty ? 0.0 : data.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    final minSales = data.isEmpty ? 0.0 : data.map((e) => e.sales).reduce((a, b) => a < b ? a : b);
    final range = maxSales - minSales;

    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          // Chart area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: data.map((weekData) {
                final normalizedHeight = range > 0
                    ? ((weekData.sales - minSales) / range) * (maxHeight - 80)
                    : 50.0;
                final barHeight = normalizedHeight < 20 ? 20.0 : normalizedHeight;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Sales value tooltip
                        if (weekData.sales > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Rp ${weekData.sales.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Bar
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Day label
                        Text(
                          weekData.day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}