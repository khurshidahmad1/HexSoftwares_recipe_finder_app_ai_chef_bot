import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // --- TYPEWRITER VARIABLES ---
  final String _titleText = "AI Chef Bot";
  final String _creditText = "by Khurshid Ahmad"; 
  
  final List<String> _descriptionLines = [
    "Your Personal AI Sous-Chef...",
    "Just tell me what is in your kitchen...",
    "Aur aj kia bnanay ka mood ha?", 
  ];

  String _displayTitle = "";
  String _displayCredit = "";
  String _displayBodyText = ""; 
  
  @override
  void initState() {
    super.initState();

    // 1. Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // 2. Start Typing Sequence
    _startTypingSequence();
  }

  void _startTypingSequence() async {
    // A. Title
    for (int i = 0; i <= _titleText.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 60)); 
      setState(() => _displayTitle = _titleText.substring(0, i));
    }

    // B. Credit
    await Future.delayed(const Duration(milliseconds: 200));
    for (int i = 0; i <= _creditText.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 40));
      setState(() => _displayCredit = _creditText.substring(0, i));
    }

    // C. Body Lines
    await Future.delayed(const Duration(milliseconds: 300));
    
    for (String line in _descriptionLines) {
      if (!mounted) return;

      if (_displayBodyText.isNotEmpty) {
        setState(() => _displayBodyText += "\n"); 
        await Future.delayed(const Duration(milliseconds: 300)); 
      }

      for (int i = 0; i < line.length; i++) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 35)); 
        setState(() {
          _displayBodyText += line[i];
        });
      }
    }

    // Wait 3 seconds then go Home
    await Future.delayed(const Duration(seconds: 3));
    _navigateToHome();
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- 1. BACKGROUND GIF ---
          Positioned.fill(
            child: Image.asset(
              'assets/splash_bg.gif', 
              fit: BoxFit.cover, 
            ),
          ),

          // --- 2. BLACK OVERLAY (Light Intensity) ---
          Positioned.fill(
            child: Container(
              // Change 0.2 to 0.0 to remove it completely
              color: Colors.black.withOpacity(0.2), 
            ),
          ),

          // --- 3. MAIN CONTENT ---
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spacer(flex: 5) means "Push everything down"
                const Spacer(flex: 6), 

                // --- PULSING LOGO ---
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20), // Thoda chhota kiya
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 60, // Thoda chhota kiya taaki neeche fit ho
                      color: Color(0xFFDD2476), 
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // --- TITLE ---
                Text(
                  _displayTitle,
                  style: TextStyle(
                    fontSize: 36, // Thoda adjust kiya
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(blurRadius: 15, color: Colors.black, offset: Offset(0, 4)),
                    ],
                  ),
                ),

                // --- CREDIT ---
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Text(
                    _displayCredit,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.orangeAccent, 
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ),

                // --- DESCRIPTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "$_displayBodyText|", 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.2,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // --- LOADING BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                    minHeight: 2,
                  ),
                ),
                
                const SizedBox(height: 20),

                // --- BOTTOM TEXT ---
                const Text(
                  "Powered by Google Gemini",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70, // Thoda brighter kiya kyunki overlay kam hai
                    letterSpacing: 1.0,
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(blurRadius: 5, color: Colors.black, offset: Offset(0, 1)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}