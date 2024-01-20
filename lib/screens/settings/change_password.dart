import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialnetworkapp/services/auth.dart';
import 'package:socialnetworkapp/utils/snackbar.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var formKey = GlobalKey<FormState>();
  String? oldPassword;
  String? newPassword;

  final user = AuthService().getCurrentUser();
  final rawuser = AuthService().getRawCurrentUser();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 45),
          child: const Text(
            'Change Password',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please enter your old password";
                        }

                        return null;
                      },
                      initialValue: oldPassword,
                      onChanged: (val) {
                        oldPassword = val;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        hintText: 'Old Password',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      validator: (val) {
                        if (val != null && val.isEmpty) {
                          return "Please enter your new password";
                        }

                        if (val == oldPassword) {
                          return "New password must not be equal password";
                        }
                        return null;
                      },
                      initialValue: newPassword,
                      onChanged: (val) {
                        newPassword = val;
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(width: 2)),
                        hintText: 'New Password',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    try {
                      final cred = EmailAuthProvider.credential(
                          email: user?.email ?? "", password: oldPassword!);
                      await rawuser!.reauthenticateWithCredential(cred);
                    } catch (e) {
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          'Old password not match',
                        );
                      }
                      return;
                    }

                    try {
                      await rawuser!.updatePassword(newPassword!);
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          'Change information successfully',
                        );
                        Navigator.of(context).pop();
                        return;
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showSnackBar(
                          context,
                          'Something wrong.',
                        );
                      }
                      return;
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  fixedSize: const Size(200, 40),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
