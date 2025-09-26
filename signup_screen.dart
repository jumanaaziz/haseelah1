import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_background.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  String selectedUserType = 'Parent'; // Default to Parent
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),

              // User Type Selection
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedUserType = 'Parent';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedUserType == 'Parent'
                                ? Color(0xFF8D61B4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Parent',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedUserType == 'Parent'
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedUserType = 'Child';
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedUserType == 'Child'
                                ? Color(0xFF8D61B4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Child',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selectedUserType == 'Child'
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(
                        hintText: 'First Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Last Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Username field only for Parent
              if (selectedUserType == 'Parent')
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              if (selectedUserType == 'Parent') SizedBox(height: 20),
              SizedBox(height: 20),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          final username = usernameController.text.trim();
                          final phone = phoneController.text.trim().replaceAll(
                            RegExp(r'[^\d]'),
                            '',
                          );
                          final password = passwordController.text.trim();
                          final confirmPassword = confirmPasswordController.text
                              .trim();
                          final firstName = firstNameController.text.trim();
                          final lastName = lastNameController.text.trim();
                          final passwordRegex = RegExp(
                            r'^(?=.*[A-Z])(?=.*\d).{8,}$',
                          );
                          final phoneRegex = RegExp(r'^0\d{9}$');

                          // Empty fields validation
                          if (email.isEmpty ||
                              phone.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty ||
                              firstName.isEmpty ||
                              lastName.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text('All fields are required!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          // Username required only for Parent
                          if (selectedUserType == 'Parent' &&
                              username.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                  'Username is required for Parent accounts!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          // Email format
                          if (!email.contains('@')) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text('Invalid email format!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          // Password strength
                          if (!passwordRegex.hasMatch(password)) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                  'Password must be at least 8 characters, contain a number and an uppercase letter!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          // Password match
                          if (password != confirmPassword) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text('Passwords do not match!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          // Phone format: starts with 0 and exactly 10 digits
                          if (!phoneRegex.hasMatch(phone)) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                  'Phone must start with 0 and be 10 digits.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            // Generate unique user ID
                            final userId = DateTime.now().millisecondsSinceEpoch
                                .toString();

                            // Check if username already exists in Firestore (only for Parent)
                            if (selectedUserType == 'Parent') {
                              final usernameQuery = await FirebaseFirestore
                                  .instance
                                  .collection('usernames')
                                  .doc(username)
                                  .get();

                              if (usernameQuery.exists) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text('Error'),
                                    content: Text('Username already exists!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                            }

                            // Check if email already exists in both collections
                            final parentEmailQuery = await FirebaseFirestore
                                .instance
                                .collection('Parents')
                                .where('email', isEqualTo: email)
                                .limit(1)
                                .get();

                            final childEmailQuery = await FirebaseFirestore
                                .instance
                                .collection('Children')
                                .where('email', isEqualTo: email)
                                .limit(1)
                                .get();

                            if (parentEmailQuery.docs.isNotEmpty ||
                                childEmailQuery.docs.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Email already exists!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }

                            // Save user data to appropriate collection
                            String collectionName = selectedUserType == 'Parent'
                                ? 'Parents'
                                : 'Children';

                            Map<String, dynamic> userData = {
                              'email': email,
                              'firstName': firstName,
                              'lastName': lastName,
                              'phone': phone,
                              'password': password,
                              'userType': selectedUserType,
                              'createdAt': Timestamp.now(),
                              'lastLogin': null,
                            };

                            // Add username only for Parent
                            if (selectedUserType == 'Parent') {
                              userData['username'] = username;
                            }

                            await FirebaseFirestore.instance
                                .collection(collectionName)
                                .doc(userId)
                                .set(userData);

                            // Save username mapping for uniqueness check (only for Parent)
                            if (selectedUserType == 'Parent') {
                              await FirebaseFirestore.instance
                                  .collection('usernames')
                                  .doc(username)
                                  .set({
                                    'uid': userId,
                                    'email': email,
                                    'userType': selectedUserType,
                                    'createdAt': Timestamp.now(),
                                  });
                            }

                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Success'),
                                content: Text(
                                  '${selectedUserType} account created successfully!\n\n'
                                  'Name: $firstName $lastName\n'
                                  'Email: $email\n'
                                  'Phone: $phone\n'
                                  'User Type: $selectedUserType\n'
                                  '${selectedUserType == 'Parent' ? 'Username: $username\n' : ''}'
                                  'All data saved to Firestore!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Error'),
                                content: Text('Sign up failed: $e'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8D61B4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
