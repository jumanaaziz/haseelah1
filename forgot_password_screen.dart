import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'auth_background.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

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
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 10),

              Text(
                'Enter your email to receive a reset link\n(No email verification required)',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // Email field
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email, color: Color(0xFF8D61B4)),
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
                  onPressed: isLoading ? null : _handleSendResetLink,
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
                          'Send Reset Link',
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

  Future<void> _handleSendResetLink() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter your email address.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
          ],
        ),
      );
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter a valid email address.'),
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

    // Generate reset code and link
    final resetCode = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);

    final resetLink =
        'https://haseela.app/reset-password?code=$resetCode&email=$email';

    try {
      print('Generating reset link for: $email');

      // Save reset request to Firestore
      await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .add({
            'email': email,
            'requestedAt': Timestamp.now(),
            'status': 'pending',
            'resetCode': resetCode,
            'resetLink': resetLink,
          });

      print('Password reset link generated and saved to Firestore!');

      // Show loading message
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Generating Reset Link...'),
            ],
          ),
          content: Text('Please wait while we prepare your reset link.'),
        ),
      );

      // Try multiple methods to send email with reset link
      bool emailSent = false;
      String errorMessage = '';

      // Method 1: Try mailto with proper encoding
      try {
        final String subject = 'Password Reset Request - Hasella';
        final String body =
            '''
Hello!

You have requested to reset your password for your Hasella account.

To reset your password, please click on the following link:

$resetLink

This link will expire in 24 hours for security reasons.

If you did not request this password reset, please ignore this email.

Best regards,
Hasella Team
        ''';

        final Uri emailUri = Uri(
          scheme: 'mailto',
          path: email,
          query:
              'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
        );

        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
          print('Email app opened successfully!');
          emailSent = true;
        }
      } catch (e) {
        print('Method 1 failed: $e');
        errorMessage = e.toString();
      }

      // Method 2: Try simple mailto without body
      if (!emailSent) {
        try {
          final Uri simpleEmailUri = Uri(
            scheme: 'mailto',
            path: email,
            query:
                'subject=${Uri.encodeComponent('Password Reset Request - Hasella')}',
          );

          if (await canLaunchUrl(simpleEmailUri)) {
            await launchUrl(simpleEmailUri);
            print('Simple email app opened successfully!');
            emailSent = true;
          }
        } catch (e) {
          print('Method 2 failed: $e');
          errorMessage = e.toString();
        }
      }

      // Method 3: Try basic mailto
      if (!emailSent) {
        try {
          final Uri basicEmailUri = Uri(scheme: 'mailto', path: email);

          if (await canLaunchUrl(basicEmailUri)) {
            await launchUrl(basicEmailUri);
            print('Basic email app opened successfully!');
            emailSent = true;
          }
        } catch (e) {
          print('Method 3 failed: $e');
          errorMessage = e.toString();
        }
      }

      if (!emailSent) {
        throw Exception('All email methods failed. Last error: $errorMessage');
      }

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Email App Opened!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your email app has been opened with a pre-filled message.\n\n'
                '📧 Email: $email\n\n'
                '📝 Please send the email to complete the password reset process.\n\n'
                '🔗 Reset Link (for reference):',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: SelectableText(
                  resetLink,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[800],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '💡 Tip: You can copy this link if needed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: resetLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.copy, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Reset link copied to clipboard!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: Icon(Icons.copy, size: 18),
              label: Text('Copy Link'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              icon: Icon(Icons.check, size: 18),
              label: Text('OK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8D61B4),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error occurred: $e');

      // Close loading dialog
      Navigator.pop(context);

      // Show error message or fallback
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text('Reset Link Generated!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email app could not be opened, but reset link has been generated:\n\n'
                '📧 Email: $email\n\n'
                '🔗 Please use this link to reset your password:\n\n'
                'Reset Link:',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: SelectableText(
                  resetLink,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange[800],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '💡 You can copy this link and send it manually via any email app',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '📱 Alternative: Open any email app manually and send this link to $email',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: resetLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.copy, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Reset link copied to clipboard!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: Icon(Icons.copy, size: 18),
              label: Text('Copy Link'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              icon: Icon(Icons.check, size: 18),
              label: Text('OK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8D61B4),
              ),
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
}
