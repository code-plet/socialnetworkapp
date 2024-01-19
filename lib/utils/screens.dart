import 'package:flutter/material.dart';
import 'package:socialnetworkapp/screens/home/add_post.dart';
import 'package:socialnetworkapp/screens/home/home.dart';
import 'package:socialnetworkapp/screens/home/personal_profile.dart';

List<Widget> screensList(String? defaultUserId) {
  return [
    const HomeScreen(),
    const AddPostScreen(),
    PersonalProfile(
      userId: defaultUserId,
    )
  ];
}
