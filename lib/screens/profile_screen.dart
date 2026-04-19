import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Logout',
          style: GoogleFonts.notoSerif(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out?',
          style: GoogleFonts.manrope(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CANCEL',
              style: GoogleFonts.manrope(
                color: AppColors.outline,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: Text(
              'LOGOUT',
              style: GoogleFonts.manrope(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final analytics = authProvider.analytics;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Text('Profile', style: AppTextStyles.headline(context).copyWith(
              fontSize: 36,
              color: AppColors.primary,
            )),
            const SizedBox(height: 32),
            // Profile Card
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: -10,
                    right: -10,
                    child: Opacity(
                      opacity: 0.05,
                      child: Icon(Icons.star, size: 120, color: Colors.white),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/profile_placeholder.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                    ]
                                  ),
                                  child: const Icon(Icons.verified, color: AppColors.onPrimary, size: 16),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.name ?? 'Loading...', style: AppTextStyles.headline(context).copyWith(
                                  fontSize: 24,
                                  color: AppColors.onSurface,
                                )),
                                const SizedBox(height: 8),
                                Text('"The heart finds rest in the remembrance of Allah."', style: AppTextStyles.headline(context).copyWith(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.normal,
                                  height: 1.4,
                                )),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user?.streak.current.toString() ?? '0', style: AppTextStyles.headline(context).copyWith(
                                          fontSize: 18,
                                          color: AppColors.primary,
                                        )),
                                        Text('DAYS STREAK', style: AppTextStyles.body(context).copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: AppColors.outline,
                                        )),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Container(width: 1, height: 32, color: AppColors.outlineVariant.withOpacity(0.3)),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(analytics?['summary']?['completed']?.toString() ?? '0', style: AppTextStyles.headline(context).copyWith(
                                          fontSize: 18,
                                          color: AppColors.primary,
                                        )),
                                        Text('PRAYERS', style: AppTextStyles.body(context).copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          color: AppColors.outline,
                                        )),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ]
              ),
            ),
            
            const SizedBox(height: 40),
            
            // App Settings Section
            Row(
              children: [
                const Icon(Icons.tune, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text('APP SETTINGS', style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppColors.outline,
                )),
              ],
            ),
            const SizedBox(height: 24),
            _buildSettingItem(
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your personal details',
              trailing: 'arrow',
              onTap: () {
                // TODO: Implement navigation to Edit Profile
              },
              context: context,
            ),
            const SizedBox(height: 16),
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                return _buildSettingItem(
                  icon: Icons.access_time,
                  title: '12-Hour Format',
                  subtitle: 'Current: ${settingsProvider.is24HourFormat ? "24h" : "12h"}',
                  trailing: 'toggle',
                  value: !settingsProvider.is24HourFormat,
                  onChanged: (val) {
                    settingsProvider.set24HourFormat(!val);
                  },
                  context: context,
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // Account Section
            Row(
              children: [
                const Icon(Icons.person_outline, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text('ACCOUNT', style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppColors.outline,
                )),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildAccountItem(Icons.logout, 'Logout', true, context, () {
                    _showLogoutConfirmation(context);
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Text('AL-MIHRAB PREMIUM V2.4.0', style: AppTextStyles.body(context).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: AppColors.outline,
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    bool? value,
    Function(bool)? onChanged,
    VoidCallback? onTap,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? (trailing == 'toggle' ? () => onChanged?.call(!(value ?? false)) : null),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.body(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      )),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.body(context).copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      )),
                    ],
                  ),
                ),
                if (trailing == 'toggle')
                  Container(
                    width: 48,
                    height: 24,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: (value ?? false) ? AppColors.primary : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: (value ?? false) ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.onPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  )
                else if (trailing == 'arrow')
                  const Icon(Icons.chevron_right, color: AppColors.outline)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountItem(IconData icon, String title, bool isError, BuildContext context, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: isError ? AppColors.error : AppColors.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: AppTextStyles.body(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isError ? AppColors.error : AppColors.onSurface,
                )),
              ),
              if (!isError)
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outlineVariant)
            ],
          ),
        ),
      ),
    );
  }
}
