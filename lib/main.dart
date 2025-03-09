import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.teal,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.teal),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  bool _isLoading = false;
  bool _isRegistering = false;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Username and password are required");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hashedPassword = hashPassword(password);
      final user = await dbHelper.loginUser(username, hashedPassword);

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
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Username and password are required");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final hashedPassword = hashPassword(password);
      await dbHelper.registerUser(username, hashedPassword);
      _showMessage("Registration successful");
      
      // Switch back to login view
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.teal,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                Center(
                  child: Icon(
                    Icons.local_hospital_rounded,
                    size: 80,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: Text(
                    _isRegistering ? "Create Account" : "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _isRegistering 
                      ? "Register to continue" 
                      : "Sign in to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Username",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "Enter your username",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Password",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),
                _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _isRegistering ? _register : _login,
                      child: Text(
                        _isRegistering ? "Register" : "Login",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isRegistering = !_isRegistering;
                      });
                    },
                    child: Text(
                      _isRegistering
                        ? "Already have an account? Login"
                        : "Don't have an account? Register",
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> patients = [];
  bool _isLoading = false;
  bool _isAddingPatient = false;

  void _addPatient() async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final gender = _genderController.text.trim();
    final symptoms = _symptomsController.text.trim();

    if (name.isEmpty || age.isEmpty || gender.isEmpty || symptoms.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    if (int.tryParse(age) == null) {
      _showMessage("Age must be a valid number");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await dbHelper.addPatient(name, int.parse(age), gender, symptoms);
      _showMessage("Patient added successfully");
      _fetchPatients();
      _clearFields();
      setState(() {
        _isAddingPatient = false;
      });
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchPatients() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final data = await dbHelper.getPatients();
      setState(() {
        patients = data;
      });
    } catch (e) {
      _showMessage("Error fetching patients: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _ageController.clear();
    _genderController.clear();
    _symptomsController.clear();
  }

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Records"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _isAddingPatient
          ? _buildAddPatientForm()
          : _buildPatientsList(),
      floatingActionButton: _isAddingPatient
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isAddingPatient = true;
                });
              },
              backgroundColor: Colors.teal,
              child: Icon(Icons.add),
            ),
    );
  }

  Widget _buildAddPatientForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isAddingPatient = false;
                    });
                  },
                ),
                SizedBox(width: 8),
                Text(
                  "Add New Patient",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              "Patient Name",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Enter patient name",
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Age",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(
                hintText: "Enter patient age",
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Text(
              "Gender",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(
                hintText: "Enter patient gender",
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Symptoms",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _symptomsController,
              decoration: InputDecoration(
                hintText: "Enter patient symptoms",
              ),
              maxLines: 3,
            ),
            SizedBox(height: 32),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _addPatient,
                    child: Text(
                      "Save Patient",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "No patients yet",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Add your first patient using the + button",
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Card(
            elevation: 1,
            margin: EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal[100],
                        child: Text(
                          patient['name'][0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.teal[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${patient['age']} years • ${patient['gender']}",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Symptoms:",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    patient['symptoms'],
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}