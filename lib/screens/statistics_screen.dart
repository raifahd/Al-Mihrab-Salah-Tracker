import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/statistics_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final int _quoteIndex = Random().nextInt(1000);

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<StatisticsProvider>().fetchAnalytics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.2)),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/top_bar_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Al-Mihrab',
                      style: AppTextStyles.headline(context).copyWith(
                        color: AppColors.primary,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      )),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.outline),
                  onPressed: () =>
                      context.read<StatisticsProvider>().fetchAnalytics(),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load analytics',
                      style: AppTextStyles.headline(context)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.fetchAnalytics(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Retry',
                        style: TextStyle(color: AppColors.onPrimary)),
                  ),
                ],
              ),
            );
          }

          if (provider.data == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final data = provider.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
                top: 100, left: 24, right: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Motivational Quote ─────────────────────────────────────
                _buildQuoteCard(context),
                
                // ── Consistency Score ──────────────────────────────────────
                _buildConsistencyCard(data, context),
                const SizedBox(height: 16),

                // ── Total Prayers + Streak ─────────────────────────────────
                Row(
                  children: [
                    Expanded(
                        child: _buildStatTile(
                      label: 'TOTAL PRAYED',
                      value: '${data.summary.completed}',
                      accent: AppColors.primary,
                      context: context,
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatTile(
                      label: 'CURRENT STREAK',
                      value:
                          '${data.streak.current} Day${data.streak.current == 1 ? '' : 's'}',
                      accent: AppColors.secondary,
                      context: context,
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                        child: _buildStatTile(
                      label: 'LONGEST STREAK',
                      value:
                          '${data.streak.longest} Day${data.streak.longest == 1 ? '' : 's'}',
                      accent: const Color(0xFFFF7E67),
                      context: context,
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildStatTile(
                      label: 'MISSED (30d)',
                      value: '${data.summary.missed}',
                      accent: AppColors.error,
                      context: context,
                    )),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 7-Day Consistency Bar Graph ────────────────────────────
                _buildWeeklyConsistencyCard(data, context),

                const SizedBox(height: 24),

                // ── Prayer Breakdown (pie + legend) ────────────────────────
                _buildBreakdownCard(data, context),

                const SizedBox(height: 24),

                // ── Per-Prayer Bar Rows ────────────────────────────────────
                _buildPerPrayerCard(data, context),

                const SizedBox(height: 24),

                // ── Insight Card ───────────────────────────────────────────
                _buildInsightCard(data, context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Motivational Quote ───────────────────────────────────────────────────

  Widget _buildQuoteCard(BuildContext context) {
    final quotes = [
      '"Masha\'Allah! Beautiful consistency in your Salah."',
      '"Alhamdulillah for the blessing of prayer."',
      '"Subhan\'Allah! Every prostration brings you closer to Jannah."',
      '"Masha\'Allah! Your dedication to Salah is truly inspiring."',
      '"Indeed, prayer prohibits immorality and wrongdoing."\n– Quran (29:45)',
      '"Let your heart find peace in Sujood."',
      '"If you want to talk to Allah, pray. If you want Allah to talk to you, read the Quran."\n– Islamic Proverb',
      '"The closest a servant is to his Lord is during prostration."\n– Hadith',
      '"Turn to Allah in prayer before you return to Him."',
      '"And He found you lost and guided you."\n– Quran (93:7)'
    ];
    final quote = quotes[_quoteIndex % quotes.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              quote,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: Colors.yellow[300], // the requested yellow
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Consistency Score Card ─────────────────────────────────────────────────

  Widget _buildConsistencyCard(AnalyticsData data, BuildContext context) {
    final pct = data.summary.consistencyScore / 100.0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerHigh,
            AppColors.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONSISTENCY SCORE',
              style: AppTextStyles.body(context).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppColors.onSurfaceVariant,
              )),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${data.summary.consistencyScore}%',
                  style: AppTextStyles.headline(context).copyWith(
                    fontSize: 40,
                    color: AppColors.primary,
                  )),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('of days had entries (30d)',
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall completion: ${data.summary.overallCompletionRate}%',
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  )),
              Text('Last 30 days',
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 11,
                    color: AppColors.outline,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // ── Generic Stat Tile ──────────────────────────────────────────────────────

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color accent,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
                color: AppColors.onSurfaceVariant,
              )),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.headline(context).copyWith(
                fontSize: 22,
                color: AppColors.onSurface,
              )),
        ],
      ),
    );
  }

  // ── 7-Day Consistency Bar Graph ────────────────────────────────────────────

  Widget _buildWeeklyConsistencyCard(AnalyticsData data, BuildContext context) {
    // Build a map of date → completedCount for fast lookup
    final completedMap = <String, int>{};
    for (final e in data.heatmap) {
      completedMap[e.date] = e.completedCount;
    }

    // Generate last 7 days (oldest → newest)
    final days = <DateTime>[];
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      days.add(now.subtract(Duration(days: i)));
    }

    final dayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Container(
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
              Text('Weekly Consistency',
                  style: AppTextStyles.headline(context).copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  )),
              Text('LAST 7 DAYS',
                  style: AppTextStyles.body(context).copyWith(
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
              children: days.map((day) {
                final key =
                    '${day.day.toString().padLeft(2, '0')}-${day.month.toString().padLeft(2, '0')}-${day.year}';
                final completedCount = completedMap[key] ?? 0;
                // Max prayers completed per day is 5
                final fillPct = (completedCount / 5.0).clamp(0.0, 1.0);
                
                // Show today as highlighted
                final isToday = day.day == now.day && 
                                day.month == now.month && 
                                day.year == now.year;
                                
                // Get 3-letter day name
                final label = dayLabels[day.weekday - 1];
                
                return _buildBarColumn(label, fillPct, isToday, context);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(String label, double fillPct, bool isToday, BuildContext context) {
    final isComplete = fillPct >= 1.0;
    // Use true blue if 5/5 prayers are done, otherwise use primary gold
    final barColor = isComplete ? const Color(0xFF38BDF8) : AppColors.primary;

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
                      color: barColor,
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
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppColors.onSurface : AppColors.outline,
          )),
        ],
      ),
    );
  }

  // ── Prayer Breakdown ───────────────────────────────────────────────────────

  Widget _buildBreakdownCard(AnalyticsData data, BuildContext context) {
    final total = data.summary.completed;
    final onTime = data.summary.onTime;
    final cong = data.summary.congregation;
    final late = data.summary.late;
    final missed = data.summary.missed;
    final grandTotal = total + missed;

    // Sweep gradient stops (on_time, congregation, late, missed)
    final onTimeFrac = grandTotal > 0 ? onTime / grandTotal.toDouble() : 0.0;
    final congFrac = grandTotal > 0 ? cong / grandTotal.toDouble() : 0.0;
    final lateFrac = grandTotal > 0 ? late / grandTotal.toDouble() : 0.0;

    final s1 = onTimeFrac;
    final s2 = s1 + congFrac;
    final s3 = s2 + lateFrac;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prayer Breakdown',
              style: AppTextStyles.headline(context)
                  .copyWith(fontSize: 18, color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Last 30 days · ${grandTotal > 0 ? grandTotal : 0} tracked',
              style: AppTextStyles.body(context)
                  .copyWith(fontSize: 11, color: AppColors.outline)),
          const SizedBox(height: 24),
          Row(
            children: [
              // Donut
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            const Color(0xFF22C55E), // On Time – emerald green
                            const Color(0xFF22C55E),
                            const Color(0xFF38BDF8), // Congregation – sky blue
                            const Color(0xFF38BDF8),
                            const Color(0xFFFF6B35), // Late – vivid orange
                            const Color(0xFFFF6B35),
                            const Color(0xFFFF4757), // Missed – hot coral
                            const Color(0xFFFF4757),
                          ],
                          stops: [
                            0.0,
                            s1,
                            s1,
                            s2,
                            s2,
                            s3,
                            s3,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainer,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('TOTAL',
                              style: AppTextStyles.body(context).copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.outline,
                              )),
                          Text('$total',
                              style: AppTextStyles.headline(context)
                                  .copyWith(fontSize: 22)),
                          Text('PRAYED',
                              style: AppTextStyles.body(context).copyWith(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.outline,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem('On Time', '$onTime',
                        const Color(0xFF22C55E), context),
                    const SizedBox(height: 10),
                    _buildLegendItem('Congregation', '$cong',
                        const Color(0xFF38BDF8), context),
                    const SizedBox(height: 10),
                    _buildLegendItem('Late', '$late',
                        const Color(0xFFFF6B35), context),
                    const SizedBox(height: 10),
                    _buildLegendItem(
                        'Missed', '$missed', const Color(0xFFFF4757), context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      String label, String value, Color color, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body(context).copyWith(
                        fontSize: 13, color: AppColors.onSurface)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(value,
            style: AppTextStyles.body(context).copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface)),
      ],
    );
  }

  // ── Per-Prayer Completion Bars ─────────────────────────────────────────────

  Widget _buildPerPrayerCard(AnalyticsData data, BuildContext context) {
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final labels = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Per Prayer',
                  style: AppTextStyles.headline(context)
                      .copyWith(fontSize: 18, color: AppColors.primary)),
              Text('COMPLETION %',
                  style: AppTextStyles.body(context).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                    color: AppColors.outline,
                  )),
            ],
          ),
          // Best / Worst callout
          if (data.bestPrayer.isNotEmpty || data.worstPrayer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (data.bestPrayer.isNotEmpty)
                  _buildPrayerBadge('🏆 ${_cap(data.bestPrayer)}',
                      AppColors.primary, context),
                if (data.bestPrayer.isNotEmpty && data.worstPrayer.isNotEmpty)
                  const SizedBox(width: 8),
                if (data.worstPrayer.isNotEmpty)
                  _buildPrayerBadge('⚠ ${_cap(data.worstPrayer)}',
                      AppColors.error, context),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ...List.generate(prayers.length, (i) {
            final stat = data.perPrayer[prayers[i]];
            final pct = stat?.completionRate ?? 0;
            final isBest = prayers[i] == data.bestPrayer;
            final isWorst = prayers[i] == data.worstPrayer;
            final barColor = isBest
                ? AppColors.primary
                : isWorst
                    ? AppColors.error
                    : AppColors.secondary;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(labels[i],
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          )),
                      Text('$pct%',
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: barColor,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (pct / 100.0).clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPrayerBadge(String text, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text,
          style: AppTextStyles.body(context).copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          )),
    );
  }

  // ── Insight Card ───────────────────────────────────────────────────────────

  Widget _buildInsightCard(AnalyticsData data, BuildContext context) {
    final String title;
    final String message;

    final rate = data.summary.overallCompletionRate;
    if (rate >= 80) {
      title = "Masha'Allah! 🌟";
      message =
          'Your overall completion rate is $rate% over the last 30 days. '
          '${data.bestPrayer.isNotEmpty ? '${_cap(data.bestPrayer)} is your strongest prayer. Keep it up!' : 'Keep maintaining this excellent consistency!'}';
    } else if (rate >= 50) {
      title = 'Good progress 📈';
      message =
          'You\'re at $rate% completion this month. '
          '${data.worstPrayer.isNotEmpty ? '${_cap(data.worstPrayer)} needs the most attention — small steps lead to big change.' : 'Keep pushing for consistency!'}';
    } else {
      title = 'Keep going 💪';
      message =
          'Every prayer counts. You\'re at $rate% this month. '
          '${data.worstPrayer.isNotEmpty ? 'Focus on ${_cap(data.worstPrayer)} first — building one habit at a time makes it sustainable.' : 'Set a small goal for tomorrow.'}';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.headline(context).copyWith(
                      fontSize: 17,
                      color: AppColors.primary,
                    )),
                const SizedBox(height: 6),
                Text(message,
                    style: AppTextStyles.body(context).copyWith(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      height: 1.6,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
