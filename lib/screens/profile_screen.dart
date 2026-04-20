import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

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

  void _showSchoolSelection(BuildContext context, AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('School of Thought', style: AppTextStyles.headline(context).copyWith(fontSize: 24)),
            const SizedBox(height: 8),
            Text('This setting affects Asr prayer time calculation.', 
              style: AppTextStyles.body(context).copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 32),
            _buildSelectionOption(
              context: context,
              title: 'Shafi, Maliki, Hanbali',
              subtitle: 'Standard calculation method',
              isSelected: authProvider.user?.settings.school == 0,
              onTap: () {
                authProvider.updateProfile(settings: {'school': 0});
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _buildSelectionOption(
              context: context,
              title: 'Hanafi',
              subtitle: 'Asr time is later',
              isSelected: authProvider.user?.settings.school == 1,
              onTap: () {
                authProvider.updateProfile(settings: {'school': 1});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDialog(BuildContext context, AuthProvider authProvider) {
    bool isUpdating = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Location Services', style: AppTextStyles.headline(context).copyWith(fontSize: 20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUpdating)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              else ...[
                const Icon(Icons.gps_fixed, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                Text('Current Registered Location', style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.bold)),
                Text('${authProvider.user?.location?.city ?? 'Unknown'}, ${authProvider.user?.location?.country ?? 'Unknown'}', 
                  style: AppTextStyles.body(context).copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 24),
                Text('Update your location to get more accurate prayer times based on where you are.', 
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(context).copyWith(fontSize: 12, color: AppColors.outline)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CLOSE', style: TextStyle(color: AppColors.outline)),
            ),
            if (!isUpdating)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  setDialogState(() => isUpdating = true);
                  await _updateLocation(context, authProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('REFRESH'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLocation(BuildContext context, AuthProvider authProvider) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await geo.placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        await authProvider.updateProfile(
          location: {
            'city': place.locality ?? place.subAdministrativeArea ?? 'Unknown',
            'country': place.country ?? 'Unknown',
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        );
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update location. Please try again.')),
        );
      }
    }
  }

  Widget _buildSelectionOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.body(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.onSurface,
                  )),
                  Text(subtitle, style: AppTextStyles.body(context).copyWith(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  )),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
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
    final userLocation = user?.location;
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
            // Redesigned Profile Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.secondary.withOpacity(0.2),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondary.withOpacity(0.1),
                          AppColors.surfaceContainer.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Profile Section with PFP and Info
                        Row(
                          children: [
                             // PFP with yellow border
                             Container(
                               padding: const EdgeInsets.all(3),
                               decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 gradient: LinearGradient(
                                   colors: [
                                     AppColors.primary,
                                     AppColors.primary.withValues(alpha: 0.2),
                                   ],
                                   begin: Alignment.topLeft,
                                   end: Alignment.bottomRight,
                                 ),
                               ),
                               child: Container(
                                 padding: const EdgeInsets.all(2),
                                 decoration: const BoxDecoration(
                                   color: AppColors.background,
                                   shape: BoxShape.circle,
                                 ),
                                 child: CircleAvatar(
                                   radius: 42,
                                   backgroundColor: const Color(0xFFE1F5FE).withValues(alpha: 0.4),
                                   child: const Icon(
                                     Icons.person_rounded,
                                     size: 48,
                                     color: Color(0xFFE3F2FD),
                                   ),
                                 ),
                               ),
                             ),
                            const SizedBox(width: 20),
                            // Name and Quote
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'Loading...',
                                    style: AppTextStyles.headline(context).copyWith(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? 'user@example.com',
                                    style: AppTextStyles.body(context).copyWith(
                                      fontSize: 13,
                                      color: AppColors.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Quote Widget
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.format_quote_rounded, color: AppColors.primary.withOpacity(0.6), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "The heart finds rest in the remembrance of Allah.",
                                  style: AppTextStyles.body(context).copyWith(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats Section
                        Row(
                          children: [
                            _buildStatBadge(
                              context,
                              user?.streak.current.toString() ?? '0',
                              'Day Streak',
                              Icons.local_fire_department_rounded,
                              AppColors.secondary,
                            ),
                            const SizedBox(width: 12),
                            _buildStatBadge(
                              context,
                              analytics?['summary']?['completed']?.toString() ?? '0',
                              'Prayers',
                              Icons.auto_awesome_rounded,
                              const Color(0xFF64B5F6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Prayer Settings Section
            Row(
              children: [
                const Icon(Icons.settings_suggest, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text('PRAYER SETTINGS', style: AppTextStyles.body(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: AppColors.outline,
                )),
              ],
            ),
            const SizedBox(height: 24),
            
            // School of Thought Widget
            _buildSettingItem(
              icon: Icons.mosque_outlined,
              title: 'School of Thought',
              subtitle: user?.settings.school == 1 ? 'Hanafi (Standard)' : 'Shafi, Maliki, Hanbali',
              trailing: 'arrow',
              onTap: () {
                _showSchoolSelection(context, authProvider);
              },
              context: context,
            ),
            const SizedBox(height: 16),
            
            // Location Services Widget
            _buildSettingItem(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              subtitle: userLocation != null 
                ? '${userLocation.city}, ${userLocation.country}' 
                : 'Not Set',
              trailing: 'arrow',
              onTap: () {
                _showLocationDialog(context, authProvider);
              },
              context: context,
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

  Widget _buildStatBadge(BuildContext context, String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: AppTextStyles.headline(context).copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.body(context).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.outline.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
