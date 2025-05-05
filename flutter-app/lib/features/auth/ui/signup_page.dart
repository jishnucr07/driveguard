import 'package:driveguard/features/auth/ui/login_page.dart';
import 'package:driveguard/features/auth/ui/profile_page.dart';
import 'package:driveguard/features/auth/ui/widgets/auth_button.dart';
import 'package:driveguard/features/auth/ui/widgets/auth_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController cnpasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: ListView(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Text(
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        color: const Color.fromARGB(255, 10, 93, 209),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    // Text(
                    //   'Welcome back you\'ve \n        been missed!',
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 18,
                    //     color: Colors.black,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    SizedBox(
                      height: 70,
                    ),
                    AuthTextField(
                      controller: userNameController,
                      isPassword: false,
                      hinText: 'Username',
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    AuthTextField(
                      controller: emailController,
                      isPassword: false,
                      hinText: 'Email',
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    AuthTextField(
                      controller: passwordController,
                      isPassword: true,
                      hinText: 'Password',
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    AuthTextField(
                      controller: cnpasswordController,
                      isPassword: true,
                      hinText: 'Confirm Password',
                    ),

                    SizedBox(
                      height: 50,
                    ),
                    AuthButton(
                      buttonText: 'Sign up',
                      onTap: () {
                        print(' email ${emailController.text}');
                        print('pass ${passwordController.text}');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileCreationPage(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  userName: userNameController.text.trim(),
                                )));
                      },
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginPage()));
                      },
                      child: Text(
                        'Already have an account',
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 111, 109, 109),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
