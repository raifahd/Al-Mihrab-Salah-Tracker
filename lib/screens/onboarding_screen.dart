import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import '../widgets/midnight_background.dart';
import '../widgets/glass_card.dart';
import 'signup_screen.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MidnightBackground(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: const [
                  InnerPeaceSlide(),
                  StayMindfulSlide(),
                  TrackJourneySlide(),
                ],
              ),
            ),
            
            // Fixed Bottom Section
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final active = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: active ? 24 : 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: active ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                    )
                  ] : [],
                ),
              );
            }),
          ),
          const SizedBox(height: 40),

          // Primary Button
          GestureDetector(
            onTap: () {
              if (_currentPage < 2) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                context.read<AuthProvider>().completeOnboarding();
              }
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFB6941A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == 2 ? 'Get Started' : 'Next',
                      style: GoogleFonts.manrope(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: AppColors.onPrimary, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Auth Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                   context.read<AuthProvider>().completeOnboarding();
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: Text(
                  'Log In',
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Container(
                height: 16,
                width: 1,
                color: AppColors.outlineVariant.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              TextButton(
                onPressed: () {
                   context.read<AuthProvider>().completeOnboarding();
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                },
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.manrope(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InnerPeaceSlide extends StatelessWidget {
  const InnerPeaceSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuC4DDaMNBrK6MR7T78mgLrSsiGAMFAFiEElglqsT6o8C63ocpbj7EryBQeybKs97dKOTBR33yzfCb7g-PBgybWXRrJ1hSxNeHXckiBpGZWbZ896oZ8nH4i-L8XaUmIJR4l5Z2FNkuvO1NP-nCU56zskPIf-mK5N3y25f4iZceqyMe5vdq3LIjXIfpZVzTScHRimjesskMwaoC-7CXR_FjDmRS29F7xwMwnucLP9_4pP0K1PeQwztHlF5eQppTy94zUbMjfQosNCfnOW',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.background, Colors.transparent, AppColors.background],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Text(
                  'Find Your Inner Peace',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    color: AppColors.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Reconnect with your faith through timely prayers and a focused heart.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StayMindfulSlide extends StatelessWidget {
  const StayMindfulSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Expanded(
          flex: 6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Image
              Container(
                width: 280,
                height: 380,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(140), bottom: Radius.circular(12)),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 60,
                      offset: const Offset(0, 30),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(140), bottom: Radius.circular(12)),
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAU29wswidZcADX6pOh1jEZf7jw7cA8pHqzi9Qo5tZURs3FxMXqLA_VMCDmRi11UGDQrIkBwEqcYxpmpTnaNgL3J2uPUPO0RONEZVUFE7VU-au-Lr6t5KiQjUPQ9D048kH3cXvs2sg17bqm-wLJdKULEvqzASkdlTO2aLky41BujdArHkNbaymuhs5MJESV3e7IrSIeAwTppCx128RaHP9wg5v8rfL16-oPJ8Yz9HOyQTVmRuqm5LgOMY6hhDfWfmaB4W5UkbjMqXQR',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Floating Reminder
              Positioned(
                top: 40,
                right: 20,
                child: const GlassCard(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0x33E9C349),
                        child: Icon(Icons.notifications_active, color: AppColors.primary, size: 16),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UPCOMING', style: TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          Text('Maghrib • 18:42', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Floating Social
              Positioned(
                bottom: 40,
                left: 20,
                child: const GlassCard(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       SizedBox(
                        width: 40,
                        height: 20,
                        child: Stack(
                          children: [
                            Positioned(left: 0, child: CircleAvatar(radius: 10, backgroundColor: Colors.grey)),
                            Positioned(left: 10, child: CircleAvatar(radius: 10, backgroundColor: Colors.blueGrey)),
                            Positioned(left: 20, child: CircleAvatar(radius: 10, backgroundColor: AppColors.primary, child: Text('+4k', style: TextStyle(fontSize: 8, color: Colors.black)))),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Praying together now', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Never Miss a Moment',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    color: AppColors.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Stay mindful with precise prayer times and gentle reminders wherever you are.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TrackJourneySlide extends StatelessWidget {
  const TrackJourneySlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Header Branding from design
        Text(
          'Al-Mihrab: Salah Tracker',
          style: GoogleFonts.notoSerif(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          flex: 6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse effect from design
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.05)),
                ),
              ),
              
              // Rotated Image card
              Transform.rotate(
                angle: -0.03, // approx -2deg
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Opacity(
                      opacity: 0.6,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAfhqAq5Gh9ZzziGI2eprQ_N76u1PCkBbepqOuFMQTLqLHxYrVC8KWIx4ynBCMhLhaF-0c-FlschoOdh97D_fX8KpqfTJY3Gz-O8aJkWCvc6pBjEvjQSQEH6hvIIUh74eGYeHpucRGeTvkfBkPymtkdZnlLM8dKGyMznn29aCnU93LXtRjsbgrsUarEWRCURnAfa-7coDhkSCy2L-0BJU_GZBXz9M6Lwxg1ceXCvnb9-1SIUf7qXAh-ZJQyy66kkvR4st8AlP6hz0rh',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Data insight
              Positioned(
                bottom: 20,
                right: 40,
                child: Transform.rotate(
                  angle: 0.05, // approx 3deg
                  child: const GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(radius: 12, backgroundColor: Color(0x33E9C349), child: Icon(Icons.auto_graph, color: AppColors.primary, size: 12)),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DAILY STREAK', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1.0)),
                                Text('12 Days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        ProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Track Your Journey',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSerif(
                    color: AppColors.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Build a lifelong habit of prayer with intuitive tracking and detailed insights.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// GlassCard and ProgressIndicator extracted to common widgets or used locally where appropriate

class ProgressIndicator extends StatelessWidget {
  const ProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.7,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 4,
              )
            ],
          ),
        ),
      ),
    );
  }
}
