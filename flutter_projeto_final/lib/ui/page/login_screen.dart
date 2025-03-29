import 'package:flutter/material.dart';
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

    User? user =
    await apiService.login(emailController.text, senhaController.text);

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logotipo_tce.png',
                height: 150,
              ),
              SizedBox(height: 30),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Digite seu e-mail",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: senhaController,
                  decoration: InputDecoration(
                    labelText: "Digite sua senha",
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
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
                  : SizedBox(
                width: 280,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF347D6B), // Cor do botão
                  ),
                  child: Text(
                      "ENTRAR",
                      style: TextStyle(color: Colors.white),
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
