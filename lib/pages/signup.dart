import 'package:flight_booking/main.dart';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController genderCtrl = TextEditingController();
  final TextEditingController dobCtrl = TextEditingController();
  final TextEditingController countryCtrl = TextEditingController();

  bool loading = false;

  // Validation states
  bool isFirstNameValid = true;
  bool isLastNameValid = true;
  bool isEmailValid = true;
  bool isPhoneValid = true;
  bool isGenderValid = true;
  bool isDobValid = true;
  bool isCountryValid = true;

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? phoneError;
  String? genderError;
  String? dobError;
  String? countryError;

  // Gender options
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();

    // Add listeners for real-time validation
    firstNameCtrl.addListener(_validateFirstName);
    lastNameCtrl.addListener(_validateLastName);
    emailCtrl.addListener(_validateEmail);
    phoneCtrl.addListener(_validatePhone);
    genderCtrl.addListener(_validateGender);
    dobCtrl.addListener(_validateDob);
    countryCtrl.addListener(_validateCountry);
  }

  void _validateFirstName() {
    setState(() {
      if (firstNameCtrl.text.isEmpty) {
        isFirstNameValid = false;
        firstNameError = 'First name cannot be empty';
      } else if (firstNameCtrl.text.length < 2) {
        isFirstNameValid = false;
        firstNameError = 'First name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(firstNameCtrl.text)) {
        isFirstNameValid = false;
        firstNameError = 'First name can only contain letters';
      } else {
        isFirstNameValid = true;
        firstNameError = null;
      }
    });
  }

  void _validateLastName() {
    setState(() {
      if (lastNameCtrl.text.isEmpty) {
        isLastNameValid = false;
        lastNameError = 'Last name cannot be empty';
      } else if (lastNameCtrl.text.length < 2) {
        isLastNameValid = false;
        lastNameError = 'Last name must be at least 2 characters';
      } else if (!RegExp(r'^[a-zA-Z]+$').hasMatch(lastNameCtrl.text)) {
        isLastNameValid = false;
        lastNameError = 'Last name can only contain letters';
      } else {
        isLastNameValid = true;
        lastNameError = null;
      }
    });
  }

  void _validateEmail() {
    setState(() {
      final email = emailCtrl.text;

      if (email.isEmpty) {
        isEmailValid = false;
        emailError = 'Email cannot be empty';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        isEmailValid = false;
        emailError = 'Please enter a valid email address';
      } else {
        isEmailValid = true;
        emailError = null;
      }
    });
  }

  void _validatePhone() {
    setState(() {
      final phone = phoneCtrl.text;

      if (phone.isEmpty) {
        isPhoneValid = false;
        phoneError = 'Phone number cannot be empty';
      } else if (!RegExp(r'^\+?[0-9\-\s]{10,15}$').hasMatch(phone)) {
        isPhoneValid = false;
        phoneError = 'Please enter a valid phone number';
      } else {
        isPhoneValid = true;
        phoneError = null;
      }
    });
  }

  void _validateGender() {
    setState(() {
      if (genderCtrl.text.isEmpty) {
        isGenderValid = false;
        genderError = 'Please select gender';
      } else {
        isGenderValid = true;
        genderError = null;
      }
    });
  }

  void _validateDob() {
    setState(() {
      if (dobCtrl.text.isEmpty) {
        isDobValid = false;
        dobError = 'Date of birth cannot be empty';
      } else {
        isDobValid = true;
        dobError = null;
      }
    });
  }

  void _validateCountry() {
    setState(() {
      if (countryCtrl.text.isEmpty) {
        isCountryValid = false;
        countryError = 'Country cannot be empty';
      } else {
        isCountryValid = true;
        countryError = null;
      }
    });
  }

  bool _validateForm() {
    _validateFirstName();
    _validateLastName();
    _validateEmail();
    _validatePhone();
    _validateGender();
    _validateDob();
    _validateCountry();

    return isFirstNameValid &&
        isLastNameValid &&
        isEmailValid &&
        isPhoneValid &&
        isGenderValid &&
        isDobValid &&
        isCountryValid;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showGenderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Gender'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: genderOptions.map((gender) {
              return ListTile(
                title: Text(gender),
                onTap: () {
                  setState(() {
                    genderCtrl.text = gender;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Future<void> signup() async {
  //   final name = nameCtrl.text.trim();
  //   final mobile = mobileCtrl.text.trim();
  //
  //   if (name.isEmpty || mobile.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please enter both name and mobile')),
  //     );
  //     return;
  //   }
  //
  //   setState(() => loading = true);
  //   try {
  //     final res = await AuthService.signup(name, mobile);
  //     if (res['success'] == true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(res['message'] ?? 'Signup successful')),
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (_) => const LoginPage()),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(res['message'] ?? 'Signup failed')),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  //   setState(() => loading = false);
  // }

  void _clearForm() {
    setState(() {
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailCtrl.clear();
      phoneCtrl.clear();
      genderCtrl.clear();
      dobCtrl.clear();
      countryCtrl.clear();

      isFirstNameValid = true;
      isLastNameValid = true;
      isEmailValid = true;
      isPhoneValid = true;
      isGenderValid = true;
      isDobValid = true;
      isCountryValid = true;

      firstNameError = null;
      lastNameError = null;
      emailError = null;
      phoneError = null;
      genderError = null;
      dobError = null;
      countryError = null;
    });
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    genderCtrl.dispose();
    dobCtrl.dispose();
    countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            const Text(
              'Create an Account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please fill in your details to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 30),

            // First Name TextField
            TextField(
              controller: firstNameCtrl,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: firstNameError,
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: isFirstNameValid ? Colors.black : Colors.red,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // Last Name TextField
            TextField(
              controller: lastNameCtrl,
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: lastNameError,
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: isLastNameValid ? Colors.black : Colors.red,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // Email TextField
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: emailError,
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: isEmailValid ? Colors.black : Colors.red,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'example@email.com',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // Phone TextField
            TextField(
              controller: phoneCtrl,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: phoneError,
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.phone_iphone_outlined,
                  color: isPhoneValid ? Colors.black : Colors.red,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: '+91-9819988776',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // Gender Field (with dropdown dialog)
            TextField(
              controller: genderCtrl,
              readOnly: true,
              onTap: _showGenderDialog,
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: genderError,
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: isGenderValid ? Colors.black : Colors.red,
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'Select your gender',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 15),

            // Date of Birth Field (with date picker)
            TextField(
              controller: dobCtrl,
              readOnly: true,
              onTap: _selectDate,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: dobError,
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: isDobValid ? Colors.black : Colors.red,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'YYYY-MM-DD',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 15),

            // Country TextField
            TextField(
              controller: countryCtrl,
              decoration: InputDecoration(
                labelText: 'Country',
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: countryError,
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: isCountryValid ? Colors.black : Colors.red,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'Enter your country',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              style: const TextStyle(fontSize: 16),
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 30),

            // Signup Button
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              ),
              //signup,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.teal,
                disabledBackgroundColor: Colors.teal.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: loading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Clear Form Button
            OutlinedButton(
              onPressed: loading ? null : _clearForm,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.black),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.clear_all, size: 18, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Clear Form',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Login Redirect
            Center(
              child: GestureDetector(
                onTap: loading
                    ? null
                    : () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                ),
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'Login here',
                        style: TextStyle(
                          color: loading ? Colors.grey : Colors.black,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}