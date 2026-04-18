import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/dashboard_provider.dart';
import '../models/prayer_times_model.dart';
import '../models/prayer_log_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DashboardProvider>().init());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by MainScreen
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: const Color(0xFF0f131f).withOpacity(0.8),
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
                          image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuAj0sBPm8IN5zOH03NlphTMiZWBMuzwgdQihdPJsFtEIr2B6rER95q9U9hUOaEN0YcI3dhC7ZlxEuknjzX5PXroIfSrysFl2bVKbp1IfantmO002s45z3La59R72gomzBA7fjfc0sHduEx_ll_hRTEOObooai3lRHIRTXn3UWT9oroZG967hCvgSSAqB8SJKccSO8a4X6P9Z4T74AGJtK4hHBQNDJnnAsofsDCnrrjREGVBQaFCN44BAb-uUchZmAIK4hjSmpBj_Ugi'),
                          fit: BoxFit.cover,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Text('RuzSalah',
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
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load dashboard', style: AppTextStyles.headline(context)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => provider.fetchDashboardData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = provider.user;
          final prayerTimes = provider.prayerTimes;
          final todayLog = provider.todayLog;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 130, left: 24, right: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text('Salam, ${user?.name ?? 'Fahd'}',
                    style: AppTextStyles.headline(context).copyWith(
                      color: AppColors.primary,
                      fontSize: 36,
                    )),
                const SizedBox(height: 4),
                Text('May your day be filled with barakah.',
                    style: AppTextStyles.body(context).copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    )),
                const SizedBox(height: 32),

                // Prayer Times Bento Card
                if (prayerTimes != null)
                  _buildPrayerTimesCard(prayerTimes, context),

                const SizedBox(height: 40),

                // Prayer Tracker Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Prayer Tracker',
                        style: AppTextStyles.headline(context).copyWith(
                          fontSize: 24,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Text('TODAY',
                          style: AppTextStyles.body(context).copyWith(
                            color: AppColors.primaryFixedDim,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          )),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Tracker Items
                if (prayerTimes != null) ...[
                  _buildTrackerList(prayerTimes, todayLog, provider, context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerTimesCard(PrayerTimesModel prayerTimes, BuildContext context) {
    // Logic to find current prayer
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    String currentPrayer = "Fajr";
    String nextTime = prayerTimes.prayers['fajr'] ?? "00:00";
    
    // Sort and find next (simplified logic)
    final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
    for (var p in prayers) {
      if (prayerTimes.prayers[p] != null && prayerTimes.prayers[p]!.compareTo(timeStr) > 0) {
        currentPrayer = p;
        nextTime = prayerTimes.prayers[p]!;
        break;
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B1F2C),
            Color(0xFF0F131F),
          ],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: -5),
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
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primaryFixedDim, size: 14),
                        const SizedBox(width: 4),
                        Text(prayerTimes.location.city.toUpperCase(),
                            style: AppTextStyles.body(context).copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppColors.primaryFixedDim,
                            ))
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(prayerTimes.hijriDate.readable,
                        style: AppTextStyles.headline(context).copyWith(
                          fontSize: 14,
                          color: AppColors.primary,
                        )),
                    const SizedBox(height: 2),
                    Text('${currentPrayer[0].toUpperCase()}${currentPrayer.substring(1)} Prayer',
                        style: AppTextStyles.headline(context).copyWith(
                          fontSize: 24,
                        )),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(nextTime,
                        style: AppTextStyles.headline(context).copyWith(
                          color: AppColors.primary,
                          fontSize: 30,
                        )),
                    Text('UPCOMING',
                        style: AppTextStyles.body(context).copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ))
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPrayerMiniBox('Fajr', Icons.wb_twilight, prayerTimes.prayers['fajr'] ?? '-', currentPrayer == 'fajr', context),
                _buildPrayerMiniBox('Dhuhr', Icons.wb_sunny_outlined, prayerTimes.prayers['dhuhr'] ?? '-', currentPrayer == 'dhuhr', context),
                _buildPrayerMiniBox('Asr', Icons.wb_sunny, prayerTimes.prayers['asr'] ?? '-', currentPrayer == 'asr', context),
                _buildPrayerMiniBox('Magh', Icons.nights_stay_outlined, prayerTimes.prayers['maghrib'] ?? '-', currentPrayer == 'maghrib', context),
                _buildPrayerMiniBox('Isha', Icons.bedtime_outlined, prayerTimes.prayers['isha'] ?? '-', currentPrayer == 'isha', context),
              ],
            )
          ],
        ),
      ]),
    );
  }

  Widget _buildTrackerList(PrayerTimesModel times, PrayerLogModel? log, DashboardProvider provider, BuildContext context) {
    final prayers = [
      {'id': 'fajr', 'title': 'Fajr', 'icon': Icons.wb_twilight},
      {'id': 'dhuhr', 'title': 'Dhuhr', 'icon': Icons.wb_sunny_outlined},
      {'id': 'asr', 'title': 'Asr', 'icon': Icons.wb_sunny},
      {'id': 'maghrib', 'title': 'Maghrib', 'icon': Icons.nights_stay_outlined},
      {'id': 'isha', 'title': 'Isha', 'icon': Icons.bedtime_outlined},
    ];

    return Column(
      children: prayers.map((p) {
        final prayerId = p['id'] as String;
        final prayerData = log?.prayers[prayerId];
        final time = times.prayers[prayerId] ?? '--:--';
        
        String subtitle = 'Time: $time';
        String status = 'empty';
        if (prayerData != null && prayerData.status != 'empty') {
          status = 'done';
          subtitle = 'Completed at ${prayerData.markedAt ?? time}';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTrackerItem(
            id: prayerId,
            title: p['title'] as String,
            subtitle: subtitle,
            icon: p['icon'] as IconData,
            status: status,
            isActive: false, // Could implement more complex "active" check
            provider: provider,
            context: context,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrayerMiniBox(String name, IconData icon, String time, bool active, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: active ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: active ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
      ),
      child: Column(
        children: [
          Text(name.toUpperCase(),
              style: AppTextStyles.body(context).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          Icon(icon, size: 24, color: active ? AppColors.primary : AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(time,
              style: AppTextStyles.body(context).copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: active ? AppColors.primary : AppColors.onSurface,
              )),
        ],
      ),
    );
  }

  Widget _buildTrackerItem(
      {required String id,
      required String title,
      required String subtitle,
      required IconData icon,
      required String status,
      required bool isActive,
      required DashboardProvider provider,
      required BuildContext context}) {
    bool isDone = status == 'done';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: isActive
            ? const Border(left: BorderSide(color: AppColors.primary, width: 4))
            : Border.all(color: AppColors.outlineVariant.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        color: isActive ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: isActive ? AppColors.primary : AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? AppColors.primary : AppColors.onSurface,
                          )),
                      Text(subtitle,
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: 12,
                            color: isActive ? AppColors.primary.withOpacity(0.6) : AppColors.onSurfaceVariant,
                            fontStyle: isActive ? FontStyle.italic : FontStyle.normal,
                          )),
                    ],
                  )
                ],
              ),
              if (isDone)
                Row(
                  children: [
                    Text('DONE',
                        style: AppTextStyles.body(context).copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        )),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.check, size: 16, color: AppColors.onPrimary),
                    )
                  ],
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: isActive ? AppColors.primary.withOpacity(0.6) : AppColors.outlineVariant, width: 2)),
                )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusButton(id, 'Missed', 'missed', provider, context),
              const SizedBox(width: 8),
              _buildStatusButton(id, 'Late', 'late', provider, context),
              const SizedBox(width: 8),
              _buildStatusButton(id, 'On Time', 'on_time', provider, context),
              const SizedBox(width: 8),
              _buildStatusButton(id, 'Congre', 'congregation', provider, context),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusButton(String prayerId, String label, String statusCode, DashboardProvider provider, BuildContext context) {
    final currentStatus = provider.todayLog?.prayers[prayerId]?.status;
    bool active = currentStatus == statusCode;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.markPrayer(prayerId, statusCode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: active ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant.withOpacity(0.1)),
          ),
          alignment: Alignment.center,
          child: Text(label.toUpperCase(),
              style: AppTextStyles.body(context).copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: active ? AppColors.primary : AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
