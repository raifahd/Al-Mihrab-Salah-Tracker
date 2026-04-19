import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/dashboard_provider.dart';
import '../models/user_model.dart';
import '../models/prayer_times_model.dart';
import '../models/prayer_log_model.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';

// ─── Prayer card state enum ────────────────────────────────────────────────

enum PrayerCardState { past, current, upcoming }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ScrollController _scrollController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(() => context.read<DashboardProvider>().init());
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity((_scrollOffset / 50).clamp(0, 0.1)),
                width: 0.5,
              ),
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: (_scrollOffset / 50).clamp(0, 1) * 12,
                sigmaY: (_scrollOffset / 50).clamp(0, 1) * 12,
              ),
              child: AppBar(
                backgroundColor: AppColors.glassBackground
                    .withOpacity((_scrollOffset / 50).clamp(0, 0.6)),
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
                          image: AssetImage('assets/images/app_logo.png'),
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
                    icon: const Icon(Icons.settings, color: AppColors.outline),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load dashboard',
                      style: AppTextStyles.headline(context)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.fetchDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = Provider.of<AuthProvider>(context).user;
          final prayerTimes = provider.prayerTimes;
          final todayLog = provider.todayLog;

          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.only(
                top: 130, left: 24, right: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting ──
                Text('Salam, ${user?.name ?? 'Fahd'}',
                    style: AppTextStyles.headline(context).copyWith(
                      color: AppColors.primary,
                      fontSize: 30,
                    )),
                const SizedBox(height: 4),
                Text('May your day be filled with barakah.',
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 32),

                // ── Prayer Times Bento Card ──
                if (prayerTimes != null)
                  _buildPrayerTimesCard(prayerTimes, user, context),

                const SizedBox(height: 40),

                // ── Tracker header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prayer Tracker',
                        style: AppTextStyles.headline(context)
                            .copyWith(fontSize: 24)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16)),
                      child: Text('TODAY',
                          style: AppTextStyles.body(context).copyWith(
                            color: AppColors.primaryFixedDim,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Tracker list ──
                if (prayerTimes != null)
                  _buildTrackerList(prayerTimes, todayLog, provider, context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Determines whether a prayer is past, current, or upcoming.
  PrayerCardState _prayerState(String prayerId, PrayerTimesModel times) {
    final prayerOrder = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    final now = DateTime.now();
    final nowStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final prayerTime = times.prayers[prayerId];
    if (prayerTime == null) return PrayerCardState.past;

    final idx = prayerOrder.indexOf(prayerId);

    // Find the next prayer's time to define the "current" window
    String? nextTime;
    for (int i = idx + 1; i < prayerOrder.length; i++) {
      final nt = times.prayers[prayerOrder[i]];
      if (nt != null) {
        nextTime = nt;
        break;
      }
    }

    if (nowStr.compareTo(prayerTime) < 0) return PrayerCardState.upcoming;
    if (nextTime == null || nowStr.compareTo(nextTime) < 0) {
      return PrayerCardState.current;
    }
    return PrayerCardState.past;
  }

  String _formatTime(String time, bool is24Hour) {
    if (time == '-' || time == '--:--') return time;
    try {
      final parts = time.split(':');
      final dt = DateTime(2024, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      return is24Hour
          ? DateFormat('HH:mm').format(dt)
          : DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return time;
    }
  }

  Widget _buildTimeText(String time,
      {required bool active, required double fontSize, Color? color}) {
    final style = GoogleFonts.notoSerif(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? (active ? AppColors.primary : AppColors.onSurface),
    );

    if (!time.contains(' ')) {
      return Text(time, style: style);
    }

    final parts = time.split(' ');
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts[0]),
          const TextSpan(text: ' '),
          TextSpan(
            text: parts[1],
            style: TextStyle(fontSize: fontSize * 0.65),
          ),
        ],
      ),
      style: style,
    );
  }

  List<InlineSpan> _buildTimeSpans(String time, {required double fontSize}) {
    if (!time.contains(' ')) {
      return [TextSpan(text: time)];
    }
    final parts = time.split(' ');
    return [
      TextSpan(text: parts[0]),
      const TextSpan(text: ' '),
      TextSpan(
        text: parts[1],
        style: GoogleFonts.notoSerif(fontSize: fontSize * 0.75),
      ),
    ];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'on_time':
        return AppColors.primary;
      case 'congregation':
        return AppColors.secondary;
      case 'late':
        return const Color(0xFFF59E0B);
      case 'missed':
        return AppColors.error;
      default:
        return AppColors.outline;
    }
  }

  // ── Prayer Times Card ──────────────────────────────────────────────────────

  Widget _buildPrayerTimesCard(
      PrayerTimesModel prayerTimes, UserModel? user, BuildContext context) {
    final is24Hour =
        Provider.of<SettingsProvider>(context).is24HourFormat;

    final city = (user?.location?.city?.isNotEmpty == true)
        ? user!.location!.city
        : (prayerTimes.location.city.isNotEmpty
            ? prayerTimes.location.city
            : 'Lahore');
    final country = (user?.location?.country?.isNotEmpty == true)
        ? user!.location!.country
        : 'PK';

    final now = DateTime.now();
    final nowStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final keys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    String currentPrayer = 'isha';
    String upcomingPrayer = 'fajr';
    String nextTimeStr = prayerTimes.prayers['fajr'] ?? '00:00';

    for (int i = 0; i < keys.length; i++) {
      final p = keys[i];
      if (prayerTimes.prayers[p] != null &&
          prayerTimes.prayers[p]!.compareTo(nowStr) > 0) {
        upcomingPrayer = p;
        nextTimeStr = prayerTimes.prayers[p]!;
        if (i > 0) currentPrayer = keys[i - 1];
        break;
      }
    }

    Duration timeTill = Duration.zero;
    try {
      final parts = nextTimeStr.split(':');
      var dt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      if (dt.isBefore(now) || dt.isAtSameMomentAs(now)) {
        dt = dt.add(const Duration(days: 1));
      }
      timeTill = dt.difference(now);
    } catch (_) {}

    final hours = timeTill.inHours;
    final mins = timeTill.inMinutes.remainder(60);
    final String countdownStr = '-${hours.toString().padLeft(2, '0')}h ${mins.toString().padLeft(2, '0')}m';
    final nextTimeFormatted = _formatTime(nextTimeStr, is24Hour);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceContainer, AppColors.background],
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: -5),
        ],
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(children: [
        const Positioned(
          top: -20,
          right: -10,
          child: Opacity(
            opacity: 0.05,
            child: Icon(Icons.star, size: 100, color: Colors.white),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primaryFixedDim, size: 14),
                      const SizedBox(width: 4),
                      Text('$city, $country'.toUpperCase(),
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AppColors.primaryFixedDim,
                          )),
                    ]),
                    const SizedBox(height: 8),
                    Text(prayerTimes.hijriDate.readable,
                        style: AppTextStyles.headline(context).copyWith(
                          fontSize: 14,
                          color: Colors.tealAccent.shade400,
                        )),
                    const SizedBox(height: 2),
                    Text(
                        '${currentPrayer[0].toUpperCase()}${currentPrayer.substring(1)} Prayer',
                        style: AppTextStyles.headline(context)
                            .copyWith(fontSize: 20)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildTimeText(nextTimeFormatted, active: true, fontSize: 30),
                    Text(countdownStr,
                        style: AppTextStyles.body(context).copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniBox('Fajr', Icons.wb_twilight,
                      _formatTime(prayerTimes.prayers['fajr'] ?? '-', is24Hour),
                      currentPrayer == 'fajr', context),
                  _miniBox('Dhuhr', Icons.wb_sunny_outlined,
                      _formatTime(prayerTimes.prayers['dhuhr'] ?? '-', is24Hour),
                      currentPrayer == 'dhuhr', context),
                  _miniBox('Asr', Icons.wb_sunny,
                      _formatTime(prayerTimes.prayers['asr'] ?? '-', is24Hour),
                      currentPrayer == 'asr', context),
                  _miniBox('Magh', Icons.nights_stay_outlined,
                      _formatTime(prayerTimes.prayers['maghrib'] ?? '-', is24Hour),
                      currentPrayer == 'maghrib', context),
                  _miniBox('Isha', Icons.bedtime_outlined,
                      _formatTime(prayerTimes.prayers['isha'] ?? '-', is24Hour),
                      currentPrayer == 'isha', context),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }

  Widget _miniBox(String name, IconData icon, String time, bool active,
      BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: active
            ? Border.all(color: AppColors.primary.withOpacity(0.2))
            : null,
      ),
      child: Column(children: [
        Text(name.toUpperCase(),
            style: AppTextStyles.body(context).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: active
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Icon(icon,
            size: 24,
            color: active
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.4)),
        const SizedBox(height: 8),
        _buildTimeText(time, active: active, fontSize: 12),
      ]),
    );
  }

  // ── Tracker List ───────────────────────────────────────────────────────────

  Widget _buildTrackerList(PrayerTimesModel times, PrayerLogModel? log,
      DashboardProvider provider, BuildContext context) {
    final is24Hour = Provider.of<SettingsProvider>(context).is24HourFormat;

    final prayers = [
      {'id': 'fajr', 'title': 'Fajr', 'icon': Icons.wb_twilight},
      {'id': 'dhuhr', 'title': 'Dhuhr', 'icon': Icons.wb_sunny_outlined},
      {'id': 'asr', 'title': 'Asr', 'icon': Icons.wb_sunny},
      {'id': 'maghrib', 'title': 'Maghrib', 'icon': Icons.nights_stay_outlined},
      {'id': 'isha', 'title': 'Isha', 'icon': Icons.bedtime_outlined},
    ];

    return Column(
      children: prayers.map((p) {
        final id = p['id'] as String;
        final prayerData = log?.prayers[id];
        final rawTime = times.prayers[id] ?? '--:--';
        final fmtTime = _formatTime(rawTime, is24Hour);
        final status = prayerData?.status ?? 'empty';
        final cardState = _prayerState(id, times);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: cardState == PrayerCardState.upcoming
              ? _buildCompactCard(
                  title: p['title'] as String,
                  icon: p['icon'] as IconData,
                  time: fmtTime,
                )
              : _buildFullCard(
                  id: id,
                  title: p['title'] as String,
                  icon: p['icon'] as IconData,
                  time: fmtTime,
                  markedAt: prayerData?.markedAt,
                  status: status,
                  cardState: cardState,
                  isExpanded: provider.isExpanded(id),
                  provider: provider,
                ),
        );
      }).toList(),
    );
  }

  // ── Compact card (upcoming prayers) ───────────────────────────────────────

  Widget _buildCompactCard({
    required String title,
    required IconData icon,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon,
                size: 20, color: AppColors.primary.withOpacity(0.35)),
          ),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                )),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Upcoming at '),
                  ..._buildTimeSpans(time, fontSize: 12),
                ],
              ),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.outline,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Full card (past + current prayers) ────────────────────────────────────

  Widget _buildFullCard({
    required String id,
    required String title,
    required IconData icon,
    required String time,
    required String? markedAt,
    required String status,
    required PrayerCardState cardState,
    required bool isExpanded,
    required DashboardProvider provider,
  }) {
    final bool isDone = status != 'empty';
    final bool isCurrent = cardState == PrayerCardState.current;
    final Color statusColor = _statusColor(status);

    // Card border: gold for current, status-tinted for done, subtle otherwise
    final border = isCurrent
        ? Border.all(color: AppColors.primary, width: 1.5)
        : isDone
            ? Border.all(color: statusColor.withOpacity(0.3))
            : Border.all(color: AppColors.outlineVariant.withOpacity(0.07));

    // Subtitle
    final String subtitle;
    if (isDone && markedAt != null) {
      subtitle = 'Completed at $markedAt';
    } else if (isCurrent) {
      subtitle = 'Ongoing now';
    } else {
      subtitle = 'Mark your progress';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: border,
        boxShadow: isDone
            ? [
                BoxShadow(
                    color: statusColor.withOpacity(0.07),
                    blurRadius: 12,
                    spreadRadius: -2)
              ]
            : isCurrent
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 14,
                        spreadRadius: -2)
                  ]
                : [],
      ),
      child: Column(
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                // Icon box
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isDone
                        ? statusColor.withOpacity(0.12)
                        : isCurrent
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon,
                      size: 22,
                      color: isDone
                          ? statusColor
                          : isCurrent
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.6)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDone
                              ? statusColor
                              : isCurrent
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                        )),
                    Text.rich(
                      TextSpan(
                        children: [
                          if (isDone && markedAt != null) ...[
                            const TextSpan(text: 'Completed at '),
                            ..._buildTimeSpans(markedAt!, fontSize: 12),
                          ] else if (isCurrent) ...[
                            const TextSpan(text: 'Ongoing now'),
                          ] else ...[
                            const TextSpan(text: 'Mark your progress'),
                          ],
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent
                            ? AppColors.primary.withOpacity(0.7)
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ]),

          // ---------- Right side: [DONE label] + rounded-square checkbox ----------
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isDone) ...[
                Text('DONE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: statusColor,
                    )),
                const SizedBox(width: 8),
              ],
              // Rounded-square checkbox
              GestureDetector(
                onTap: () => provider.toggleCard(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? statusColor.withOpacity(0.2)
                        : (isExpanded && !isDone) // Tapped but not yet marked
                            ? AppColors.primary.withOpacity(0.15)
                            : isCurrent
                                ? AppColors.primary.withOpacity(0.08)
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDone
                          ? statusColor
                          : (isExpanded || isCurrent)
                              ? AppColors.primary
                              : AppColors.outline.withOpacity(0.5),
                      width: 1.8,
                    ),
                  ),
                  child: isDone
                      ? Icon(Icons.check_rounded,
                          size: 18, color: statusColor)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Status buttons — slide in when expanded ──
      AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        child: (isExpanded || isDone)
            ? Column(
                children: [
                  const SizedBox(height: 14),
                  const Divider(color: Color(0x0DFFFFFF), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statusBtn(id, 'MISSED', 'missed', status, provider),
                      const SizedBox(width: 8),
                      _statusBtn(id, 'LATE', 'late', status, provider),
                      const SizedBox(width: 8),
                      _statusBtn(id, 'ON TIME', 'on_time', status, provider),
                      const SizedBox(width: 8),
                      _statusBtn(id, 'CONGRE', 'congregation', status, provider),
                    ],
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    ],
  ),
);
}

  Widget _statusBtn(String prayerId, String label, String statusCode,
      String currentStatus, DashboardProvider provider) {
    final bool active = currentStatus == statusCode;
    final Color color = _statusColor(statusCode);

    return Expanded(
      child: GestureDetector(
        onTap: () => provider.markPrayer(prayerId, statusCode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? color.withOpacity(0.18)
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: active
                    ? color.withOpacity(0.5)
                    : AppColors.outlineVariant.withOpacity(0.1)),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: active ? color : AppColors.onSurfaceVariant,
              )),
        ),
      ),
    );
  }
}
