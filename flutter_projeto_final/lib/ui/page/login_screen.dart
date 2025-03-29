import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_projeto_final/ui/page/home_screen.dart';
import 'package:flutter_projeto_final/data/api_service.dart';
import 'package:flutter_projeto_final/data/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;
  String? errorMessage;

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    User? user = await apiService.login(emailController.text, senhaController.text);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
      );
    } else {
      setState(() {
        errorMessage = "E-mail ou senha incorretos!";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/logotipo_tce.svg',
              height: 100,
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Digite seu e-mail"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: senhaController,
              decoration: InputDecoration(labelText: "Digite sua senha"),
              obscureText: true,
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: Text("ENTRAR"),
            ),
          ],
        ),
      ),
    );
  }
}
