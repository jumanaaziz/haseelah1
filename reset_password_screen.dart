import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_background.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetCode;

  const ResetPasswordScreen({
    Key? key,
    required this.email,
    required this.resetCode,
  }) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
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
                width: 150,
                fit: BoxFit.contain,
              ),

              SizedBox(height: 40),

              // Title
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10),

              Text(
                'Enter your new password for:\n${widget.email}',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // New Password field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: newPasswordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF8D61B4)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Color(0xFF8D61B4),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
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

              // Confirm Password field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Confirm New Password',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(0xFF8D61B4),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Color(0xFF8D61B4),
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Reset Password button
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

              // Back to Login
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Login',
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
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter both password fields.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
          ],
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Passwords do not match.'),
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
      // Verify the reset code and email
      final resetQuery = await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .where('email', isEqualTo: widget.email)
          .where('resetCode', isEqualTo: widget.resetCode)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (resetQuery.docs.isEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: Text('Invalid or expired reset link.'),
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

      // Update the password reset request as completed
      await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .doc(resetQuery.docs.first.id)
          .update({
            'status': 'completed',
            'newPassword': newPassword,
            'completedAt': Timestamp.now(),
          });

      // Also save the new password to the user's document
      await FirebaseFirestore.instance
          .collection('Parents')
          .doc('parent001')
          .update({
            'password': newPassword,
            'lastPasswordUpdate': Timestamp.now(),
          });

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Success!'),
          content: Text(
            'Password reset successfully!\n\n'
            'Email: ${widget.email}\n\n'
            'You can now log in with your new password.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.popUntil(context, (route) => route.isFirst);
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
          content: Text('Failed to reset password: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
          ],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
