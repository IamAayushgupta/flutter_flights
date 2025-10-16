import 'package:flight_booking/pages/signup.dart';
import 'package:flutter/material.dart';
import '../AppConstants.dart' as AppContants;
import '../main.dart';
import '../services/auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  bool loading = false;
  bool isNameValid = true;
  bool isMobileValid = true;

  // For showing error messages
  String? nameError;
  String? mobileError;

  @override
  void initState() {
    super.initState();

    // Listen to text changes for real-time validation
    nameCtrl.addListener(_validateName);
    mobileCtrl.addListener(_validateMobile);
  }

  void _validateName() {
    setState(() {
      if (nameCtrl.text.isEmpty) {
        isNameValid = false;
        nameError = 'Name cannot be empty';
      } else if (nameCtrl.text.length < 2) {
        isNameValid = false;
        nameError = 'Name must be at least 2 characters';
      } else {
        isNameValid = true;
        nameError = null;
      }
    });
  }

  void _validateMobile() {
    setState(() {
      final mobile = mobileCtrl.text;

      if (mobile.isEmpty) {
        isMobileValid = false;
        mobileError = 'Mobile number cannot be empty';
      } else if (!RegExp(r'^[0-9]{10}$').hasMatch(mobile)) {
        isMobileValid = false;
        mobileError = 'Please enter a valid 10-digit mobile number';
      } else {
        isMobileValid = true;
        mobileError = null;
      }
    });
  }
  void _clearForm() {
    setState(() {
      nameCtrl.clear();
      mobileCtrl.clear();
      isNameValid = true;
      isMobileValid = true;
      nameError = null;
      mobileError = null;
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final name = nameCtrl.text.trim();
    final mobile = mobileCtrl.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both name and mobile')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      final res = await AuthService.login(name, mobile);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Login successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    setState(() => loading = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),centerTitle: true,),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              const Text('Welcome Back!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                    errorText: nameError,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  suffixIcon: nameCtrl.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => nameCtrl.clear(),
                  )
                      : null,
                ),
                style: TextStyle(fontSize: 16),
                onChanged: (value) {
                  // Real-time validation happens in the listener
                },
              ),

              const SizedBox(height: 20),

              // Mobile Number TextField
              TextField(
                controller: mobileCtrl,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: mobileError,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: Icon(
                    Icons.phone,
                    color: Colors.black,
                  ),
                  suffixIcon: mobileCtrl.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => mobileCtrl.clear(),
                  )
                      : null,
                ),
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 16),
                onChanged: (value) {
                  // Real-time validation happens in the listener
                },
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login',style: TextStyle(
                  color: Colors.white
                ),),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  ),
                  child: const Text('Don\'t have an account? Signup here',style: TextStyle(color: Colors.black),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
