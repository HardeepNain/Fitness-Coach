// Suggested code may be subject to a license. Learn more: ~LicenseLog:4159227077.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:4077420049.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:218952118.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3597413221.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:4103458399.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:4040748964.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1146446976.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1811742142.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1196000977.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:763277315.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1493938278.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:825782410.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2238610906.
import 'package:flutter/material.dart';

import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                    
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Navigate to the forgot password screen
                     Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  ForgotPasswordScreen()),
                  );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(onPressed: (){
                   Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                    (Route<dynamic> route) => false,
                  );
                }, child: Text("Sign Up")),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
