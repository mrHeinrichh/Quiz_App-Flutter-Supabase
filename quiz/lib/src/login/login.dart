import 'package:flutter/material.dart';
import 'package:quiz/config/supabase_config.dart';
import 'package:quiz/src/quiz/quiz_list_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final res = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.session != null && res.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => QuizListScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: Check your credentials")),
        );
      }
    } catch (e) {
      print("Login failed with error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Login",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 32),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: signIn,
                    child: Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
