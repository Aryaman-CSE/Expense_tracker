import 'package:basecode/Auth/Sign_Up_Page.dart';
import 'package:basecode/Home_Page.dart';
import 'package:basecode/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Log extends StatefulWidget {
  const Log({super.key});

  @override
  State<Log> createState() => _LogState();
}

class _LogState extends State<Log> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void displayMessageToUser(String message, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> loginUser() async {
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pop(context); 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(userId: '', username: '',)),
      );
    } catch (e) {
      Navigator.pop(context); 
      displayMessageToUser('Error: ${e.toString()}', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(66, 150, 144, 1),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: LogClipPath(),
              child: Container(
                height: screenHeight,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 90,
              right: 40,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: Colors.white,
                elevation: double.maxFinite,
                child: const Icon(Icons.arrow_back),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 140),
                  Container(
                    height: 250,
                    width: 390,
                    child: const Text(
                      'Spend Smarter \nSave More.',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                  Container(
                    height: 55,
                    width: 390,
                    child: Text('Log In', style: TextStyle(fontSize:44, color: Colors.white, fontWeight: FontWeight.w800),),
                  ),
                  const SizedBox(height: 70),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'digitaldemons@gmail.com',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: '****************',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 50,
                    width: 240,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: loginUser,
                          child: const Text(
                            'Log In',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 20,
                    width: 235,
                    child: Row(
                      children: [
                        const Text(
                          'Don\'t have an account?',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 20),
        ),
        Container(
          height: 60,
          width: 330,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            color: Colors.white70,
          ),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 30),
              Icon(icon, size: 29),
              const SizedBox(width: 25),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                  ),
                  obscureText: obscureText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LogClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0, size.height * 0.35);
    path.cubicTo(size.width * 0.3, size.height * 0.5, 3 * (size.width / 4),
        size.height * 0.35, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
