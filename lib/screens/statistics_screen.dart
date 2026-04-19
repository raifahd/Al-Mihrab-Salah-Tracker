import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Handled by MainScreen
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: AppColors.background.withOpacity(0.8),
              elevation: 0,
              titleSpacing: 24,
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/top_bar_logo.png'),
                        fit: BoxFit.cover,
                      )
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Al-Mihrab', style: AppTextStyles.headline(context).copyWith(
                    color: AppColors.primary,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  )),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.primary),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Stats grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CONSISTENCY SCORE', style: AppTextStyles.body(context).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.onSurfaceVariant,
                        )),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('94%', style: AppTextStyles.headline(context).copyWith(
                              fontSize: 36,
                              color: AppColors.primary,
                            )),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text('+2% from last week', style: AppTextStyles.body(context).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              )),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                         Container(
                           height: 6,
                           width: double.infinity,
                           decoration: BoxDecoration(
                             color: AppColors.surfaceContainerHighest,
                             borderRadius: BorderRadius.circular(3),
                           ),
                           child: FractionallySizedBox(
                             alignment: Alignment.centerLeft,
                             widthFactor: 0.94,
                             child: Container(
                               decoration: BoxDecoration(
                                 color: AppColors.primary,
                                 borderRadius: BorderRadius.circular(3),
                               ),
                             ),
                           ),
                         )
                      ],
                    ),
                  )
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL PRAYERS', style: AppTextStyles.body(context).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.onSurfaceVariant,
                        )),
                        const SizedBox(height: 8),
                        Text('1,248', style: AppTextStyles.headline(context).copyWith(
                          fontSize: 24,
                          color: AppColors.onSurface,
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: const Border(left: BorderSide(color: AppColors.secondary, width: 4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CURRENT STREAK', style: AppTextStyles.body(context).copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.onSurfaceVariant,
                        )),
                        const SizedBox(height: 8),
                        Text('18 Days', style: AppTextStyles.headline(context).copyWith(
                          fontSize: 24,
                          color: AppColors.onSurface,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Weekly Consistency Bar Graph
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weekly Consistency', style: AppTextStyles.headline(context).copyWith(
                        fontSize: 20,
                        color: AppColors.primary,
                      )),
                      Text('LAST 7 DAYS', style: AppTextStyles.body(context).copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.outline,
                      )),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 150,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBarColumn('SUN', 0.85, false, context),
                        _buildBarColumn('MON', 1.0, false, context),
                        _buildBarColumn('TUE', 0.90, false, context),
                        _buildBarColumn('WED', 1.0, false, context),
                        _buildBarColumn('THU', 0.95, false, context),
                        _buildBarColumn('FRI', 1.0, true, context),
                        _buildBarColumn('SAT', 0.80, false, context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Prayer Breakdown Pie Chart
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prayer Breakdown', style: AppTextStyles.headline(context).copyWith(
                    fontSize: 20,
                    color: AppColors.primary,
                  )),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      // Pie Chart implementation mock
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    AppColors.primary, // 65%
                                    AppColors.primary,
                                    AppColors.secondary, // 20%
                                    AppColors.secondary,
                                    AppColors.surfaceContainerHighest, // 10%
                                    AppColors.surfaceContainerHighest,
                                    AppColors.error, // 5%
                                    AppColors.error,
                                  ],
                                  stops: [0.0, 0.65, 0.65, 0.85, 0.85, 0.95, 0.95, 1.0],
                                )
                              ),
                            ),
                            Container(
                              width: 120,
                              height: 120,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceContainer,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('TOTAL', style: AppTextStyles.body(context).copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.outline,
                                  )),
                                  Text('35', style: AppTextStyles.headline(context).copyWith(
                                    fontSize: 24,
                                    color: AppColors.onSurface,
                                  )),
                                  Text('PRAYERS', style: AppTextStyles.body(context).copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.outline,
                                  )),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          children: [
                            _buildLegendItem('On Time', '23', AppColors.primary, context),
                            const SizedBox(height: 12),
                            _buildLegendItem('Congregation', '7', AppColors.secondary, context),
                            const SizedBox(height: 12),
                            _buildLegendItem('Late', '3', AppColors.surfaceContainerHighest, context),
                            const SizedBox(height: 12),
                            _buildLegendItem('Missed', '2', AppColors.error, context),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Insights Message
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Masha\'Allah!', style: AppTextStyles.headline(context).copyWith(
                          fontSize: 18,
                          color: AppColors.primary,
                        )),
                        const SizedBox(height: 4),
                        Text('Your consistency in Fajr has improved by 15% this month. Keeping up with congregation prayers can help maintain this momentum.', style: AppTextStyles.body(context).copyWith(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarColumn(String label, double fillPct, bool isHighlighted, BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: fillPct,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isHighlighted ? AppColors.secondary : AppColors.primary,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.body(context).copyWith(
            fontSize: 10,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? AppColors.secondary : AppColors.outline,
          )),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body(context).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            )),
          ],
        ),
        Text(value, style: AppTextStyles.body(context).copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        )),
      ],
    );
  }
}
