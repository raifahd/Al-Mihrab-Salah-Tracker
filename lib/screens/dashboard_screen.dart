import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAj0sBPm8IN5zOH03NlphTMiZWBMuzwgdQihdPJsFtEIr2B6rER95q9U9hUOaEN0YcI3dhC7ZlxEuknjzX5PXroIfSrysFl2bVKbp1IfantmO002s45z3La59R72gomzBA7fjfc0sHduEx_ll_hRTEOObooai3lRHIRTXn3UWT9oroZG967hCvgSSAqB8SJKccSO8a4X6P9Z4T74AGJtK4hHBQNDJnnAsofsDCnrrjREGVBQaFCN44BAb-uUchZmAIK4hjSmpBj_Ugi'),
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
                  icon: const Icon(Icons.settings, color: AppColors.outline),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text('Salam, Fahd', style: AppTextStyles.headline(context).copyWith(
              color: AppColors.primary,
              fontSize: 36,
            )),
            const SizedBox(height: 4),
            Text('May your day be filled with barakah.', style: AppTextStyles.body(context).copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            )),
            const SizedBox(height: 32),
            
            // Prayer Times Bento Card
            Container(
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
              child: Stack(
                children: [
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
                                  Text('ISTANBUL, TR', style: AppTextStyles.body(context).copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: AppColors.primaryFixedDim,
                                  ))
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Asr Prayer', style: AppTextStyles.headline(context).copyWith(
                                fontSize: 24,
                              )),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('15:42', style: AppTextStyles.headline(context).copyWith(
                                color: AppColors.primary,
                                fontSize: 30,
                              )),
                              Text('STARTS IN 12 MINS', style: AppTextStyles.body(context).copyWith(
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
                          _buildPrayerMiniBox('Fajr', Icons.wb_twilight, '05:12', false, context),
                          _buildPrayerMiniBox('Dhuhr', Icons.wb_sunny_outlined, '13:04', false, context),
                          _buildPrayerMiniBox('Asr', Icons.wb_sunny, '15:42', true, context),
                          _buildPrayerMiniBox('Magh', Icons.nights_stay_outlined, '18:21', false, context),
                          _buildPrayerMiniBox('Isha', Icons.bedtime_outlined, '19:54', false, context),
                        ],
                      )
                    ],
                  ),
                ]
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Prayer Tracker Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prayer Tracker', style: AppTextStyles.headline(context).copyWith(
                  fontSize: 24,
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Text('TODAY', style: AppTextStyles.body(context).copyWith(
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
            _buildTrackerItem(
              title: 'Fajr',
              subtitle: 'Completed at 05:25',
              icon: Icons.wb_twilight,
              status: 'done',
              isActive: false,
              context: context
            ),
            const SizedBox(height: 16),
            _buildTrackerItem(
              title: 'Dhuhr',
              subtitle: 'Mark your progress',
              icon: Icons.wb_sunny_outlined,
              status: 'empty',
              isActive: false,
              context: context
            ),
            const SizedBox(height: 16),
            _buildTrackerItem(
              title: 'Asr',
              subtitle: 'Ongoing now',
              icon: Icons.notifications_active,
              status: 'active',
              isActive: true,
              context: context
            ),
            const SizedBox(height: 16),
            _buildTrackerItem(
              title: 'Maghrib',
              subtitle: 'Upcoming at 18:21',
              icon: Icons.nights_stay_outlined,
              status: 'upcoming',
              isActive: false,
              context: context
            ),
            const SizedBox(height: 16),
            _buildTrackerItem(
              title: 'Isha',
              subtitle: 'Upcoming at 19:54',
              icon: Icons.bedtime_outlined,
              status: 'upcoming',
              isActive: false,
              context: context
            ),
          ],
        ),
      ),
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
          Text(name.toUpperCase(), style: AppTextStyles.body(context).copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: active ? AppColors.primary : AppColors.onSurfaceVariant
          )),
          const SizedBox(height: 8),
          Icon(icon, size: 24, color: active ? AppColors.primary : AppColors.primary.withOpacity(0.4)),
          const SizedBox(height: 8),
          Text(time, style: AppTextStyles.body(context).copyWith(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: active ? AppColors.primary : AppColors.onSurface,
          )),
        ],
      ),
    );
  }

  Widget _buildTrackerItem({required String title, required String subtitle, required IconData icon, required String status, required bool isActive, required BuildContext context}) {
    bool isUpcoming = status == 'upcoming';
    return Opacity(
      opacity: isUpcoming ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUpcoming ? AppColors.surfaceContainer.withOpacity(0.4) : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: isActive ? const Border(left: BorderSide(color: AppColors.primary, width: 4)) : Border.all(color: AppColors.outlineVariant.withOpacity(0.05)),
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
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Icon(icon, color: isActive ? AppColors.primary : (isUpcoming ? AppColors.onSurfaceVariant : AppColors.primary)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.body(context).copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isActive ? AppColors.primary : AppColors.onSurface,
                        )),
                        Text(subtitle, style: AppTextStyles.body(context).copyWith(
                          fontSize: 12,
                          color: isActive ? AppColors.primary.withOpacity(0.6) : AppColors.onSurfaceVariant,
                          fontStyle: isActive ? FontStyle.italic : FontStyle.normal,
                        )),
                      ],
                    )
                  ],
                ),
                if (status == 'done')
                  Row(
                    children: [
                      Text('DONE', style: AppTextStyles.body(context).copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      )),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: const Icon(Icons.check, size: 16, color: AppColors.onPrimary),
                      )
                    ],
                  )
                else if (status != 'upcoming')
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isActive ? AppColors.primary.withOpacity(0.6) : AppColors.outlineVariant, width: 2)
                    ),
                  )
              ],
            ),
            if (!isUpcoming) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatusButton('Missed', 'default', context),
                  const SizedBox(width: 8),
                  _buildStatusButton('Late', 'default', context),
                  const SizedBox(width: 8),
                  _buildStatusButton('On Time', status == 'done' ? 'active' : 'default', context),
                  const SizedBox(width: 8),
                  _buildStatusButton('Congre', 'default', context),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, String type, BuildContext context) {
    bool active = type == 'active';
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary.withOpacity(0.3) : AppColors.outlineVariant.withOpacity(0.1)),
        ),
        alignment: Alignment.center,
        child: Text(label.toUpperCase(), style: AppTextStyles.body(context).copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant
        )),
      ),
    );
  }
}
