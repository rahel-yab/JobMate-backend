import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_mate/core/presentation/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate data refresh
    setState(() => _isRefreshing = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8), // Light teal background
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF238471),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Top colored section with logo and animated welcome
              Container(
                width: double.infinity,
                color: const Color(0xFF238471),
                padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png', // Replace with your logo path
                        height: 90,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        l10n.welcomeBack,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.yourAiCareerBuddy,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // "What would you like to do?" text with animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    l10n.whatWouldYouLikeToDo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF144A3F),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Feature cards with pull-to-refresh and animation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(8),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75, // Adjusted for taller cards
                    children: [
                      _buildFeatureCard(
                        context,
                        title: l10n.cvAnalysis,
                        description: l10n.getFeedbackOnResume,
                        icon: Icons.description,
                        route: Routes.cvAnalysis,
                      ),
                      _buildFeatureCard(
                        context,
                        title: l10n.jobSearch,
                        description: l10n.findPerfectJobMatches,
                        icon: Icons.work_outline,
                        route: Routes.jobSearch,
                      ),
                      _buildFeatureCard(
                        context,
                        title: l10n.interviewPrep,
                        description: l10n.practiceWithMockInterviews,
                        icon: Icons.record_voice_over,
                        route: Routes.interviewPrep,
                      ),
                      // _buildFeatureCard(
                      //   context,
                      //   title: l10n.skillBoost,
                      //   description: l10n.getPersonalizedLearningPlan,
                      //   icon: Icons.school,
                      //   route: Routes.home, // Replace with real route if exists
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String route,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // Trigger a slight scale-up animation on tap
        });
        context.go(route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF238471)),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF144A3F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 70, 70, 70),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}