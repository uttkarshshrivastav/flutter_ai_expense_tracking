// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:upi_parser_ai/upi_parser_ai.dart';


// import '../../../../core/database/database_helper.dart';
// import '../../insights/repository/insight_repository.dart';

// class AnalyticsDashboard extends StatelessWidget {
//   const AnalyticsDashboard({super.key, required this.apiKey});

//   final String apiKey;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: FutureBuilder<_DashboardData>(
//           future: _loadData(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             final data = snapshot.data!;
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _InsightPanel(text: data.insight),
//                   const SizedBox(height: 26),
//                   const _SectionTitle('Monthly Expenses'),
//                   const SizedBox(height: 12),
//                   _ChartFrame(
//                     child: _MonthlyExpensesChart(data.monthlyExpenses),
//                   ),
//                   const SizedBox(height: 26),
//                   const _SectionTitle('Category Distribution'),
//                   const SizedBox(height: 12),
//                   _ChartFrame(child: _CategoryChart(data.categoryDistribution)),
//                   const SizedBox(height: 26),
//                   const _SectionTitle('Top Merchants'),
//                   const SizedBox(height: 12),
//                   _ChartFrame(child: _TopMerchantsChart(data.topMerchants)),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<_DashboardData> _loadData() async {
//     final databaseHelper = DatabaseHelper();
//     final insightRepository = InsightRepository(
//       databaseHelper: databaseHelper,
//       groqClient: GroqClient(apiKey: apiKey),
//     );

//     final monthlyExpenses = await databaseHelper.getMonthlyExpenses();
//     final categoryDistribution = await databaseHelper.getCategoryDistribution();
//     final topMerchants = await databaseHelper.getTopMerchants();
//     final insight = await insightRepository.fetchAiAdvice();

//     return _DashboardData(
//       monthlyExpenses: monthlyExpenses,
//       categoryDistribution: categoryDistribution,
//       topMerchants: topMerchants,
//       insight: insight,
//     );
//   }
// }

// class _DashboardData {
//   const _DashboardData({
//     required this.monthlyExpenses,
//     required this.categoryDistribution,
//     required this.topMerchants,
//     required this.insight,
//   });

//   final List<Map<String, dynamic>> monthlyExpenses;
//   final List<Map<String, dynamic>> categoryDistribution;
//   final List<Map<String, dynamic>> topMerchants;
//   final String insight;
// }

// class _InsightPanel extends StatelessWidget {
//   const _InsightPanel({required this.text});

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         border: Border.all(color: Colors.grey[200]!),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.auto_awesome,
//               color: Colors.black54,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'AI Budget Insights',
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: Colors.grey[800],
//                     fontSize: 14,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ChartFrame extends StatelessWidget {
//   const _ChartFrame({required this.child});

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         border: Border.all(color: Colors.grey[200]!),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: child,
//     );
//   }
// }

// class _MonthlyExpensesChart extends StatelessWidget {
//   const _MonthlyExpensesChart(this.rows);

//   final List<Map<String, dynamic>> rows;

//   @override
//   Widget build(BuildContext context) {
//     if (rows.isEmpty) return const _EmptyChart();

//     final maxY =
//         rows
//             .map((row) => ((row['total'] as num?)?.toDouble() ?? 0))
//             .fold<double>(0, (max, value) => value > max ? value : max) *
//         1.2;

//     return SizedBox(
//       height: 220,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           maxY: maxY <= 0 ? 1 : maxY,
//           barTouchData: const BarTouchData(enabled: false),
//           gridData: const FlGridData(show: false),
//           borderData: FlBorderData(show: false),
//           titlesData: FlTitlesData(
//             leftTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 28,
//                 getTitlesWidget: (value, _) {
//                   final index = value.toInt();
//                   if (index < 0 || index >= rows.length) {
//                     return const SizedBox.shrink();
//                   }
//                   final row = rows[index];
//                   return Text(
//                     row['day'].toString(),
//                     style: const TextStyle(color: Colors.black54, fontSize: 10),
//                   );
//                 },
//               ),
//             ),
//           ),
//           barGroups: List.generate(rows.length, (index) {
//             final amount = (rows[index]['total'] as num?)?.toDouble() ?? 0;
//             return BarChartGroupData(
//               x: index,
//               barRods: [
//                 BarChartRodData(
//                   toY: amount,
//                   width: 18,
//                   color: Colors.grey[700],
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(5),
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// class _CategoryChart extends StatelessWidget {
//   const _CategoryChart(this.rows);

//   final List<Map<String, dynamic>> rows;

//   @override
//   Widget build(BuildContext context) {
//     if (rows.isEmpty) return const _EmptyChart();

//     final total = rows.fold<double>(
//       0,
//       (sum, row) => sum + ((row['total'] as num?)?.toDouble() ?? 0),
//     );
//     final colors = [
//       Colors.grey[700]!,
//       const Color(0xFF8A817C),
//       const Color(0xFFB5A99F),
//       Colors.grey[500]!,
//       const Color(0xFF6B705C),
//       Colors.grey[300]!,
//     ];

//     return Column(
//       children: [
//         SizedBox(
//           height: 230,
//           child: PieChart(
//             PieChartData(
//               centerSpaceRadius: 0,
//               sectionsSpace: 0,
//               pieTouchData: PieTouchData(enabled: false),
//               sections: List.generate(rows.length, (index) {
//                 final amount = (rows[index]['total'] as num?)?.toDouble() ?? 0;
//                 final percent = total == 0 ? 0 : amount / total * 100;
//                 return PieChartSectionData(
//                   value: amount,
//                   color: colors[index % colors.length],
//                   radius: 92,
//                   title: '${percent.toStringAsFixed(0)}%',
//                   titleStyle: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ),
//         const SizedBox(height: 14),
//         Wrap(
//           spacing: 12,
//           runSpacing: 8,
//           children: List.generate(rows.length, (index) {
//             return Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 10,
//                   height: 10,
//                   color: colors[index % colors.length],
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   rows[index]['category'].toString(),
//                   style: const TextStyle(color: Colors.black54, fontSize: 12),
//                 ),
//               ],
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }

// class _TopMerchantsChart extends StatelessWidget {
//   const _TopMerchantsChart(this.rows);

//   final List<Map<String, dynamic>> rows;

//   @override
//   Widget build(BuildContext context) {
//     if (rows.isEmpty) return const _EmptyChart();

//     final maxY =
//         rows
//             .map((row) => ((row['total'] as num?)?.toDouble() ?? 0))
//             .fold<double>(0, (max, value) => value > max ? value : max) *
//         1.2;

//     return SizedBox(
//       height: 220,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           maxY: maxY <= 0 ? 1 : maxY,
//           barTouchData: const BarTouchData(enabled: false),
//           gridData: const FlGridData(show: false),
//           borderData: FlBorderData(show: false),
//           titlesData: FlTitlesData(
//             leftTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             rightTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             topTitles: const AxisTitles(
//               sideTitles: SideTitles(showTitles: false),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 reservedSize: 46,
//                 getTitlesWidget: (value, _) {
//                   final index = value.toInt();
//                   if (index < 0 || index >= rows.length) {
//                     return const SizedBox.shrink();
//                   }
//                   final merchant = rows[index]['merchant'].toString();
//                   return Padding(
//                     padding: const EdgeInsets.only(top: 6),
//                     child: SizedBox(
//                       width: 56,
//                       child: Text(
//                         merchant,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: Colors.black54,
//                           fontSize: 10,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           barGroups: List.generate(rows.length, (index) {
//             final amount = (rows[index]['total'] as num?)?.toDouble() ?? 0;
//             return BarChartGroupData(
//               x: index,
//               barRods: [
//                 BarChartRodData(
//                   toY: amount,
//                   width: 28,
//                   color: Colors.grey[700],
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(6),
//                   ),
//                 ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   const _SectionTitle(this.title);

//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       title,
//       style: const TextStyle(
//         color: Colors.black87,
//         fontSize: 18,
//         fontWeight: FontWeight.w700,
//       ),
//     );
//   }
// }

// class _EmptyChart extends StatelessWidget {
//   const _EmptyChart();

//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox(
//       height: 160,
//       child: Center(child: Text('No data for this month')),
//     );
//   }
// }




import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:upi_parser_ai/upi_parser_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Added dotenv import

import '../../../../core/database/database_helper.dart';
import '../../insights/repository/insight_repository.dart';

class AnalyticsDashboard extends StatelessWidget {
  // Removed the required apiKey parameter so it matches main.dart perfectly!
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<_DashboardData>(
          future: _loadData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InsightPanel(text: data.insight),
                  const SizedBox(height: 26),
                  const _SectionTitle('Monthly Expenses'),
                  const SizedBox(height: 12),
                  _ChartFrame(
                    child: _MonthlyExpensesChart(data.monthlyExpenses),
                  ),
                  const SizedBox(height: 26),
                  const _SectionTitle('Category Distribution'),
                  const SizedBox(height: 12),
                  _ChartFrame(child: _CategoryChart(data.categoryDistribution)),
                  const SizedBox(height: 26),
                  const _SectionTitle('Top Merchants'),
                  const SizedBox(height: 12),
                  _ChartFrame(child: _TopMerchantsChart(data.topMerchants)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<_DashboardData> _loadData() async {
    final databaseHelper = DatabaseHelper();
    
    // Safely pull the API key directly from the environment variables here
    final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    
    final insightRepository = InsightRepository(
      databaseHelper: databaseHelper,
      groqClient: GroqClient(apiKey: apiKey),
    );

    final monthlyExpenses = await databaseHelper.getMonthlyExpenses();
    final categoryDistribution = await databaseHelper.getCategoryDistribution();
    final topMerchants = await databaseHelper.getTopMerchants();
    final insight = await insightRepository.fetchAiAdvice();

    return _DashboardData(
      monthlyExpenses: monthlyExpenses,
      categoryDistribution: categoryDistribution,
      topMerchants: topMerchants,
      insight: insight,
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.monthlyExpenses,
    required this.categoryDistribution,
    required this.topMerchants,
    required this.insight,
  });

  final List<Map<String, dynamic>> monthlyExpenses;
  final List<Map<String, dynamic>> categoryDistribution;
  final List<Map<String, dynamic>> topMerchants;
  final String insight;
}

class _InsightPanel extends StatelessWidget {
  const _InsightPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.black54,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Budget Insights',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartFrame extends StatelessWidget {
  const _ChartFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _MonthlyExpensesChart extends StatelessWidget {
  const _MonthlyExpensesChart(this.rows);

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();

    final maxY =
        rows
            .map((row) => ((row['total'] as num?)?.toDouble() ?? 0))
            .fold<double>(0, (max, value) => value > max ? value : max) *
        1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY <= 0 ? 1 : maxY,
          barTouchData: const BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= rows.length) {
                    return const SizedBox.shrink();
                  }
                  final row = rows[index];
                  return Text(
                    row['day'].toString(),
                    style: const TextStyle(color: Colors.black54, fontSize: 10),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(rows.length, (index) {
            final amount = (rows[index]['total'] as num?)?.toDouble() ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  width: 18,
                  color: Colors.grey[700],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart(this.rows);

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();

    final total = rows.fold<double>(
      0,
      (sum, row) => sum + ((row['total'] as num?)?.toDouble() ?? 0),
    );
    final colors = [
      Colors.grey[700]!,
      const Color(0xFF8A817C),
      const Color(0xFFB5A99F),
      Colors.grey[500]!,
      const Color(0xFF6B705C),
      Colors.grey[300]!,
    ];

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 0,
              sectionsSpace: 0,
              pieTouchData: PieTouchData(enabled: false),
              sections: List.generate(rows.length, (index) {
                final amount = (rows[index]['total'] as num?)?.toDouble() ?? 0;
                final percent = total == 0 ? 0 : amount / total * 100;
                return PieChartSectionData(
                  value: amount,
                  color: colors[index % colors.length],
                  radius: 92,
                  title: '${percent.toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(rows.length, (index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  color: colors[index % colors.length],
                ),
                const SizedBox(width: 6),
                Text(
                  rows[index]['category'].toString(),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class _TopMerchantsChart extends StatelessWidget {
  const _TopMerchantsChart(this.rows);

  final List<Map<String, dynamic>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const _EmptyChart();

    final maxY =
        rows
            .map((row) => ((row['total'] as num?)?.toDouble() ?? 0))
            .fold<double>(0, (max, value) => value > max ? value : max) *
        1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY <= 0 ? 1 : maxY,
          barTouchData: const BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= rows.length) {
                    return const SizedBox.shrink();
                  }
                  final merchant = rows[index]['merchant'].toString();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: SizedBox(
                      width: 56,
                      child: Text(
                        merchant,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(rows.length, (index) {
            final amount = (rows[index]['total'] as num?)?.toDouble() ?? 0;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  width: 28,
                  color: Colors.grey[700],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 160,
      child: Center(child: Text('No data for this month')),
    );
  }
}