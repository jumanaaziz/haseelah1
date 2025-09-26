import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_background.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String resetCode;

  const OtpScreen({Key? key, required this.email, required this.resetCode})
    : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Print OTP code for debugging
    print('OTP Code for ${widget.email}: ${widget.resetCode}');
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthBackground(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),

              SizedBox(height: 20),

              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 40),

              // Title
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10),

              Text(
                'Enter the verification code and your new password',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // OTP Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter OTP code',
                    prefixIcon: Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF8D61B4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.menu,
                        color: Color(0xFF8D61B4),
                        size: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // New Password Input Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF8D61B4)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Reset Password Button
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleResetPassword,
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
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20),

              // Resend Code
              TextButton(
                onPressed: _resendCode,
                child: Text(
                  'Resend Code',
                  style: TextStyle(color: Color(0xFF8D61B4), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (otp.isEmpty || newPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both OTP code and new password.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
          ],
        ),
      );
      return;
    }

    // Password validation
    final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!passwordRegex.hasMatch(newPassword)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text(
            'Password must be at least 8 characters long and contain at least one uppercase letter and one digit.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
          ],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Check if OTP matches
      if (otp != widget.resetCode) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('Invalid OTP code. Please try again.\n\nExpected: ${widget.resetCode}\nEntered: $otp'),
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

      // Save password reset to Firestore
      await _updatePasswordViaFirestore(widget.email, newPassword);

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Success!'),
          content: Text(
            'Password reset successfully!\n\n'
            'Email: ${widget.email}\n'
            'New Password: $newPassword\n\n'
            'You can now log in with your new password.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Go back to login
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to reset password: $error'),
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
  }

  Future<void> _updatePasswordViaFirestore(
    String email,
    String newPassword,
  ) async {
    // Save password reset request to Firestore
    await FirebaseFirestore.instance.collection('password_reset_requests').add({
      'email': email,
      'newPassword': newPassword,
      'resetAt': Timestamp.now(),
      'status': 'completed',
      'resetCode': widget.resetCode,
    });
  }

  Future<void> _resendCode() async {
    // Generate new reset code
    final newCode = DateTime.now().millisecondsSinceEpoch.toString().substring(
      8,
    );

    // Save new reset request
    await FirebaseFirestore.instance.collection('password_reset_requests').add({
      'email': widget.email,
      'requestedAt': Timestamp.now(),
      'status': 'pending',
      'resetCode': newCode,
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Code Resent!'),
        content: Text(
          'A new verification code has been sent.\n\n'
          'New Code: $newCode\n\n'
          'Please use this code to reset your password.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
        ],
      ),
    );
  }
}
