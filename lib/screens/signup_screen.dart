import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/midnight_background.dart';
import '../widgets/glass_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to the Terms and Conditions'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final success = await context.read<AuthProvider>().signup(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final error = context.read<AuthProvider>().error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Signup failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: MidnightBackground(
        pattern: BackgroundPattern.celestial,
        child: SafeArea(
          child: Row(
            children: [
              if (isDesktop)
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(64),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Branding
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceContainerLow,
                                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/app_logo.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Al-Mihrab',
                                  style: GoogleFonts.notoSerif(
                                    color: AppColors.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'SALAH TRACKER',
                                  style: GoogleFonts.manrope(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 64),
                        Text(
                          'Your Sacred\nJourney Begins Here.',
                          style: GoogleFonts.notoSerif(
                            color: AppColors.onSurface,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Track your prayers, stay mindful of your goals, and find your daily peace with Al-Mihrab.',
                          style: GoogleFonts.manrope(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 18,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Stats or small feature highlights
                        _buildFeatureHighlight(Icons.auto_graph, 'Progress tracking'),
                        const SizedBox(height: 16),
                        _buildFeatureHighlight(Icons.notifications_active_outlined, 'Timely reminders'),
                        const SizedBox(height: 16),
                        _buildFeatureHighlight(Icons.people_outline, 'Community focus'),
                      ],
                    ),
                  ),
                ),
              Expanded(
                flex: 1,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isDesktop) ...[
                            // Compact branding for mobile
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceContainerLow,
                                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 15,
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/app_logo.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Al-Mihrab',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSerif(
                                color: AppColors.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'SALAH TRACKER',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4.0,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],

                          GlassCard(
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: GoogleFonts.notoSerif(
                                      color: AppColors.onSurface,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start your mindful journey today.',
                                    style: GoogleFonts.manrope(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Name Field
                                  _buildLabel('FULL NAME'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    hint: 'Fahd bin Ruz',
                                    icon: Icons.person_outline,
                                    controller: _nameController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please enter your name';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Email Field
                                  _buildLabel('EMAIL ADDRESS'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    hint: 'fahd@example.com',
                                    icon: Icons.alternate_email,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'Please enter your email';
                                      if (!value.contains('@')) return 'Enter a valid email';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Password Field
                                  _buildLabel('PASSWORD'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    hint: '••••••••',
                                    icon: Icons.lock_outline,
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: AppColors.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.length < 6) return 'Password too short';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Confirm Password Field
                                  _buildLabel('CONFIRM PASSWORD'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    hint: '••••••••',
                                    icon: Icons.verified_user_outlined,
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: AppColors.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                    validator: (value) {
                                      if (value != _passwordController.text) return 'Passwords do not match';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Terms Checkbox
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _agreeToTerms,
                                          onChanged: (value) => setState(() => _agreeToTerms = value!),
                                          activeColor: AppColors.primary,
                                          checkColor: AppColors.onPrimary,
                                          side: BorderSide(color: AppColors.onSurfaceVariant.withOpacity(0.3)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'I agree to the Terms of Service & Privacy Policy',
                                          style: GoogleFonts.manrope(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Create Button
                                  GestureDetector(
                                    onTap: authProvider.status == AuthStatus.authenticating ? null : _handleSignup,
                                    child: Container(
                                      width: double.infinity,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [AppColors.primary, Color(0xFFB6941A)],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.2),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: authProvider.status == AuthStatus.authenticating
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                                                ),
                                              )
                                            : Text(
                                                'CREATE ACCOUNT',
                                                style: GoogleFonts.manrope(
                                                  color: AppColors.onPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already a member?',
                                style: GoogleFonts.manrope(
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Log In',
                                  style: GoogleFonts.manrope(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        color: AppColors.onSurfaceVariant.withOpacity(0.6),
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.manrope(color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(color: AppColors.onSurfaceVariant.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1),
        ),
        errorStyle: GoogleFonts.manrope(fontSize: 10, color: AppColors.error),
      ),
    );
  }
}
