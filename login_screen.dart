import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_background.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

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
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: identifierController,
                decoration: InputDecoration(
                  hintText: 'Email or Username',
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
                obscureText: true,
                controller: passwordController,
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
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _handleLogin(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8D61B4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Forgot Password link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF8D61B4),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8D61B4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both identifier and password.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
          ],
        ),
      );
      return;
    }

    try {
      String email = identifier;

      // If identifier is username, get email from Firestore
      if (!identifier.contains('@')) {
        final usernameDoc = await FirebaseFirestore.instance
            .collection('usernames')
            .doc(identifier)
            .get();

        if (!usernameDoc.exists) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Error'),
              content: Text('Username not found!'),
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

        final uid = usernameDoc.data()?['uid'];
        final userType = usernameDoc.data()?['userType'] ?? 'Parent';

        if (uid == null) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Error'),
              content: Text('User not found!'),
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

        // Get user data from appropriate collection
        String collectionName = userType == 'Parent' ? 'Parents' : 'Children';
        final userDoc = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(uid)
            .get();

        if (userDoc.exists) {
          email = userDoc.data()?['email'] ?? '';
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Error'),
              content: Text('User not found!'),
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

      // Verify password by checking both collections
      bool loginSuccessful = false;
      String userType = '';
      String firstName = '';
      String lastName = '';

      // Check Parents collection
      final parentQuery = await FirebaseFirestore.instance
          .collection('Parents')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (parentQuery.docs.isNotEmpty) {
        final userData = parentQuery.docs.first.data();
        if (userData['password'] == password) {
          loginSuccessful = true;
          userType = 'Parent';
          firstName = userData['firstName'] ?? '';
          lastName = userData['lastName'] ?? '';
        }
      }

      // Check Children collection if not found in Parents
      if (!loginSuccessful) {
        final childQuery = await FirebaseFirestore.instance
            .collection('Children')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (childQuery.docs.isNotEmpty) {
          final userData = childQuery.docs.first.data();
          if (userData['password'] == password) {
            loginSuccessful = true;
            userType = 'Child';
            firstName = userData['firstName'] ?? '';
            lastName = userData['lastName'] ?? '';
          }
        }
      }

      if (!loginSuccessful) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('Invalid email or password!'),
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

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Success'),
          content: Text(
            'Logged in successfully!\n\n'
            'Welcome back, $firstName $lastName!\n\n'
            'Email: $email\n'
            'User Type: $userType',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: Text('Continue'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Login failed: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
          ],
        ),
      );
    }
  }
}
