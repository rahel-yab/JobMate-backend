import 'package:flutter/material.dart';

import 'package:job_mate/features/auth/presentation/pages/login_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    // Configure bounce animation for the button
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Repeat with reverse for bounce effect
    _buttonAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 249, 247),
      body: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            // Logo
            Image.asset(
              'assets/logo.jpg',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 40),
            // App Name
            const Text(
              'JOBMATE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF009688),
              ),
            ),
             // Welcome Message
            const Text(
              'Your AI Career Companion!',
              style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 142, 140, 140)),
            ),
            const SizedBox(height: 25),
            // Horizontal row of icon-text pairs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // AI powered
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.brain, size: 40, color: const Color(0xFF009688)),
                    const SizedBox(height: 5),
                    const Text('AI powered', style: TextStyle(fontSize: 16),),
                  ],
                ),
                const SizedBox(width: 20), // Spacing between pairs
                // Career Focus
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cases_outlined, size: 40, color: const Color(0xFF009688)),
                    const SizedBox(height: 5),
                    const Text('Career Focus',style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(width: 20), // Spacing between pairs
                // Smart Insights
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_outlined, size: 40, color: const Color(0xFF009688)),
                    const SizedBox(height: 5),
                    const Text('Smart Insights',style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
           
            const SizedBox(height: 30),
            // Animated "Get Started" button
            AnimatedBuilder(
              animation: _buttonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _buttonAnimation.value,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate with slide transition
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const LoginPage(),
                          transitionsBuilder: (_, animation, __, child) {
                            const begin = Offset(1.0, 0.0); // Slide from right
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);
                            return SlideTransition(position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: const Color(0xFF009688),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Get Started',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


// auto_awesome_outlined
//cases_outlined