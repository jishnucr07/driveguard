import 'dart:io';

import 'package:driveguard/features/auth/logic/auth_cubit.dart';
import 'package:driveguard/features/home/presentation/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:driveguard/features/auth/ui/widgets/auth_button.dart';
import 'package:driveguard/features/auth/ui/widgets/auth_textfield.dart';

class ProfileCreationPage extends StatefulWidget {
  final String userName;
  final String email;
  final String password;
  const ProfileCreationPage({
    Key? key,
    required this.userName,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController expController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? _avatarPath;

  Future<void> _pickAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _avatarPath = result.files.single.path;
      });
    }
  }

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
                      const SizedBox(
                        height: 50,
                      ),
                      Text(
                        'Create Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          color: const Color.fromARGB(255, 10, 93, 209),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _avatarPath != null
                              ? FileImage(File(_avatarPath!))
                              : null,
                          child: _avatarPath == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      AuthTextField(
                        controller: fullNameController,
                        isPassword: false,
                        hinText: 'Full Name',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      AuthTextField(
                        controller: ageController,
                        isPassword: false,
                        hinText: 'Age',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      AuthTextField(
                        controller: expController,
                        isPassword: false,
                        hinText: 'Years of Experience as a Driver',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      AuthTextField(
                        controller: phoneController,
                        isPassword: false,
                        hinText: 'Phone Number',
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      AuthButton(
                        buttonText: 'Save Profile',
                        onTap: () {
                          if (_formKey.currentState!.validate() &&
                              _avatarPath != null) {
                            print(widget.email);
                            print(widget.password);
                            // Save profile logic here
                            context.read<AuthCubit>().signUp(
                                  uname: widget.userName,
                                  fullName: fullNameController.text,
                                  email: widget.email,
                                  password: widget.password,
                                  phoneNumber: phoneController.text,
                                  age: int.tryParse(ageController.text) ?? 0,
                                  exp: int.tryParse(expController.text) ?? 0,
                                  avatar: File(_avatarPath!),
                                );
                          }
                        },
                      ),
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
