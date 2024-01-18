import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/layouts/main_layout.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/screens/auth/auth.dart';
import 'package:socialnetworkapp/screens/auth/create_profile.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<LocalUser?>(context);
    print(user.toString());

    if (user == null) {
      return const Auth();
    }

    if (user.displayName == null) {
      return const CreateProfile();
    } else {
      return const MainLayout();
    }
  }
}
