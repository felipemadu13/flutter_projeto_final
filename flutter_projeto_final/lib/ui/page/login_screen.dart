import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projeto_final/ui/page/home_screen.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Autentica o usuário com FirebaseAuth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      // Verifica se o e-mail do usuário está verificado
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        // Desconecta o usuário
        await _auth.signOut();

        // Exibe uma mensagem informando que o e-mail precisa ser verificado
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Seu e-mail não está verificado. Verifique seu e-mail antes de acessar o sistema.',
            ),
          ),
        );

        setState(() {
          isLoading = false;
        });
        return;
      }

      // Navega para a HomeScreen após o login bem-sucedido
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao realizar o login: ${e.toString()}";
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
              const SizedBox(height: 30),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Digite seu E-mail",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: senhaController,
                  decoration: const InputDecoration(
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
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        SizedBox(
                          width: 280,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF347D6B),
                            ),
                            child: const Text(
                              "ENTRAR",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 280,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CadastroScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                            ),
                            child: const Text(
                              "CADASTRAR-SE",
                              style: TextStyle(color: Colors.white),
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

  @override
  void dispose() {
    // Libera os controladores de texto ao sair da tela
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }
}