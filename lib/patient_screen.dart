import 'package:flutter/material.dart';
import 'package:graminswasthya/chatbot_screen.dart';
import 'package:graminswasthya/database_helper.dart';
import 'package:graminswasthya/login_screen.dart';
import 'package:graminswasthya/chatbot_screen.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> patients = [];
  bool _isLoading = false;
  bool _isAddingPatient = false;
  String _selectedLanguage = 'Hindi';
  
  final List<String> _languages = [
    'Hindi',
    'Telugu',
    'Gujarati',
    'Marathi',
    'English',
  ];

  void _addPatient() async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final gender = _genderController.text.trim();
    final language = _selectedLanguage;

    if (name.isEmpty || age.isEmpty || gender.isEmpty) {
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
      await dbHelper.addPatient(name, int.parse(age), gender, language);
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _ageController.clear();
    _genderController.clear();
    _selectedLanguage = 'Hindi'; // Reset to default language
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
        title: const Text("Patient Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
            focusColor: Colors.teal,
              onPressed: () {
                setState(() {
                  _isAddingPatient = true;
                });
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildAddPatientForm() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.teal),
                  onPressed: () {
                    setState(() {
                      _isAddingPatient = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  "Add New Patient",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "Patient Name",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Enter patient name",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Age",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(
                hintText: "Enter patient age",
                prefixIcon: Icon(Icons.calendar_today),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              "Gender",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _genderController,
              decoration: const InputDecoration(
                hintText: "Enter patient gender",
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Preferred Language",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedLanguage,
                  icon: const Icon(Icons.arrow_drop_down),
                  elevation: 16,
                  style: TextStyle(color: Colors.grey[800], fontSize: 16),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLanguage = newValue!;
                    });
                  },
                  items: _languages.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          const Icon(Icons.language, color: Colors.teal),
                          const SizedBox(width: 10),
                          Text(value),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _addPatient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Save Patient",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
            const SizedBox(height: 16),
            Text(
              "No patients yet",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first patient using the + button",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatbotScreen(
                    patientName: patient['name'],
                    patientLanguage: patient['symptoms'], 
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal[100],
                          radius: 24,
                          child: Text(
                            patient['name'][0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.teal[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patient['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${patient['age']} years • ${patient['gender']}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.language, color: Colors.teal[700], size: 16),
                              const SizedBox(width: 4),
                              Text(
                                patient['symptoms'], // DB field is still named 'symptoms' but contains language
                                style: TextStyle(
                                  color: Colors.teal[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.teal[400],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}