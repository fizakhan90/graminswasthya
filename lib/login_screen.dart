import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:graminswasthya/database_helper.dart';
import 'package:graminswasthya/patient_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _healthcareIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  
  bool _isLoading = false;
  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _healthcareIdController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _login() async {
    final healthcareId = _healthcareIdController.text.trim();
    final password = _passwordController.text.trim();

    if (healthcareId.isEmpty || password.isEmpty) {
      _showMessage("Healthcare Worker ID and password are required");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hashedPassword = hashPassword(password);
      final user = await dbHelper.loginUser(healthcareId, hashedPassword);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientScreen()),
        );
      } else {
        _showMessage("Invalid credentials");
      }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _register() async {
    final healthcareId = _healthcareIdController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (healthcareId.isEmpty || name.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    if (password != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hashedPassword = hashPassword(password);
      await dbHelper.registerUser(healthcareId, hashedPassword, name);
      _showMessage("Registration successful");
      
      _nameController.clear();
      _confirmPasswordController.clear();
      
      setState(() {
        _isRegistering = false;
      });
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleAuthMode() {
    _animationController.reset();
    setState(() {
      _isRegistering = !_isRegistering;
      if (_isRegistering) {
        _passwordController.clear();
      } else {
        _nameController.clear();
        _confirmPasswordController.clear();
        _passwordController.clear();
      }
    });
    _animationController.forward();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.teal.shade50, Colors.white],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Icon(
                              Icons.local_hospital_rounded,
                              size: 60,
                              color: Colors.teal[700],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Text(
                            _isRegistering ? "Create Account" : "Welcome Back",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          Text(
                            _isRegistering 
                              ? "Register to continue" 
                              : "Sign in to continue",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          Text(
                            "Healthcare Worker ID",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _healthcareIdController,
                            decoration: InputDecoration(
                              hintText: "Enter your healthcare worker ID",
                              prefixIcon: const Icon(Icons.badge_outlined),
                            ),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          
                          if (_isRegistering) ...[
                            Text(
                              "Full Name",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: "Enter your full name",
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          Text(
                            "Password",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                            textInputAction: _isRegistering ? TextInputAction.next : TextInputAction.done,
                          ),
                          const SizedBox(height: 20),
                          
                          if (_isRegistering) ...[
                            Text(
                              "Confirm Password",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                hintText: "Confirm your password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 20),
                          ],
                          
                          const SizedBox(height: 20),
                          
                          _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ElevatedButton(
                                onPressed: _isRegistering ? _register : _login,
                                child: Text(
                                  _isRegistering ? "Create Account" : "Sign In",
                                ),
                              ),
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isRegistering
                                  ? "Already have an account?"
                                  : "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleAuthMode,
                                child: Text(
                                  _isRegistering ? "Sign In" : "Register",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
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
            ),
          ),
        ),
      ),
    );
  }
}