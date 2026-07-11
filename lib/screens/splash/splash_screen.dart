import 'dart:async';
import 'package:al_musarmon/screens/home_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    
    // 500 milliseconds ke baad logo ko fade-in karwane ke liye
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // 3 seconds ke baad automatically Home Screen par redirect karne ke liye
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)], // NewSaleScreen wala same gradient theme
          ),
        ),
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2), // 2 seconds mein smooth fade-in hoga
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shop/App Icon Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded, // Aap isey checkroom_rounded ya shopping_bag_outlined bhi kar sakte hain
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // App/Shop Main Name
              const Text(
                'Al Musarmon',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              // Tagline or Subtitle
              Text(
                'Smart POS & Stock Management',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48),
              // Bottom Loading Indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}