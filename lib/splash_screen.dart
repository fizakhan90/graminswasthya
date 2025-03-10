import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graminswasthya/language.dart';
import 'package:graminswasthya/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  int _currentLanguageIndex = 0;
  List<Language> languages = Language.languageList();
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(_animationController);
    
    _startLanguageCycle();
    
    Timer(Duration(seconds: 4), () {
      _timer?.cancel();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }
  
  void _startLanguageCycle() {
    _animationController.forward();
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _animationController.reset();
        _currentLanguageIndex = (_currentLanguageIndex + 1) % languages.length;
        _animationController.forward();
      });
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                languages[_currentLanguageIndex].graminSwasthya,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                languages[_currentLanguageIndex].welcomeText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                languages[_currentLanguageIndex].name,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              "Rural Health Chatbot",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}