import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_list_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showLogoutMessage;

  const LoginScreen({super.key, this.showLogoutMessage = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.showLogoutMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda telah berjaya log keluar 🌸'),
            backgroundColor: Colors.pinkAccent,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final emailText = _emailController.text.trim();
    final passwordText = _passwordController.text.trim();

    if (emailText.isEmpty || passwordText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila isi emel dan kata laluan!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailText,
        password: passwordText,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TaskListScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log masuk gagal'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'My Task Manager 🌸',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.pink,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sila log masuk untuk mengurus tugasan anda',
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Emel',
                  prefixIcon: Icon(Icons.email, color: Colors.pink),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Kata Laluan',
                  prefixIcon: Icon(Icons.lock, color: Colors.pink),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.pink))
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Log Masuk', style: TextStyle(fontSize: 16)),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Belum ada akaun? Daftar Sini', style: TextStyle(color: Colors.pink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}