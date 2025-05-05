import 'package:driveguard/features/auth/logic/auth_cubit.dart';
import 'package:driveguard/features/auth/ui/signup_page.dart';
import 'package:driveguard/features/auth/ui/widgets/auth_button.dart';
import 'package:driveguard/features/auth/ui/widgets/auth_textfield.dart';
import 'package:driveguard/features/home/presentation/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<AuthCubit, AuthStates>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => HomePage()));
            }
            if (state is AuthError) {
              print('error is ${state.message}');
            }
          },
          child: Form(
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
                        'Login here',
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
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 200),
                        child: InkWell(
                          onTap: () {},
                          child: Text(
                            'Forgot your password?',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 10, 93, 209),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      AuthButton(
                        buttonText: 'Sign in',
                        onTap: () {
                          context.read<AuthCubit>().login(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim());
                        },
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()));
                        },
                        child: Text(
                          'Create new account',
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
      ),
    );
  }
}
