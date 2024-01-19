import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialnetworkapp/models/local_user.dart';
import 'package:socialnetworkapp/screens/settings/profile_settings.dart';
import 'package:socialnetworkapp/services/auth.dart';

import '../../widget/post_card.dart';

class PersonalProfile extends StatefulWidget {
  const PersonalProfile({super.key});

  @override
  State<PersonalProfile> createState() => _PersonalProfileState();
}

class _PersonalProfileState extends State<PersonalProfile> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    comments = fetchComment();
    likes = fetchLikes()
;  }

  Future<int> fetchComment() async {
    int count = 0;

    FirebaseFirestore db = FirebaseFirestore.instance;
    AuthService auth = AuthService();
    QuerySnapshot<Map<String, dynamic>> comments = await db.collectionGroup('comments').where("uid", isEqualTo: auth.getCurrentUser()?.uid).get();
    comments.docs.forEach((comment) {
          print(comment.data().toString());
          count = count+1;
    });
    return count;
  }

  Future<int> fetchLikes() async {
    int count = 0;

    FirebaseFirestore db = FirebaseFirestore.instance;
    
    AuthService auth = AuthService();
    QuerySnapshot<Map<String, dynamic>> posts = await db.collection('posts').where('uid', isEqualTo: auth.getCurrentUser()?.uid).get();
    posts.docs.forEach((post) {
      print(post.data().toString());
      List likes = post.data()['likes'] as List;

      count = count+likes.length;
    });
    return count;
  }
  
  late Future<int> comments;
  late Future<int> likes;
  
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  Uint8List? photo;

  dynamic image = const AssetImage("assets/images/empty_avatar.png");

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<LocalUser?>(context);
    String displayName = user?.displayName ?? "";
    String photoUrl = user?.photoURL ?? "";

    return Scaffold(
      body: Stack(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundImage: photo != null
                                ? MemoryImage(photo!)
                                : photoUrl.isNotEmpty
                                ? NetworkImage(
                              user!.photoURL.toString(),
                            )
                                : const AssetImage("assets/images/empty_avatar.png")
                            as ImageProvider<Object>,
                            radius: 50,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          //Icon(Icons.person),
                          Text(user!.displayName.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        ],
                      ),
                      if(user.email != null) Row(
                        children: [
                          Icon(Icons.email),
                          Text(user!.email.toString(), ),
                        ],
                      ),
                    ],
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('posts').where("uid", isEqualTo: user?.uid).snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      return Column(
                        children: [
                          Text(
                            snapshot.data!.docs.length.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          ),

                          Text("Posts", style: TextStyle(color: Colors.grey.shade700), )
                        ],
                      );
                    }
                  ),
                  FutureBuilder(
                    future: comments,
                    builder: (context, snapshot) {
                      if(snapshot.hasError){
                        final error = snapshot.error;
                        print(snapshot.error.toString());
                        return Text("error");
                      }
                      if(snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                        return Column(
                          children: [
                            Text(
                              snapshot.data.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), ),
                            Text("Comments", style: TextStyle(color: Colors.grey.shade700), ),
                          ],
                        );
                      } else return CircularProgressIndicator();
                    }
                  ),
                  FutureBuilder<Object>(
                    future: likes,
                      builder: (context, snapshot) {
                        if(snapshot.hasError){
                          final error = snapshot.error;
                          print(snapshot.error.toString());
                          return Text("error");
                        }
                        if(snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
                          return Column(
                            children: [
                              Text(
                                snapshot.data.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), ),
                              Text("Likes", style: TextStyle(color: Colors.grey.shade700), ),
                            ],
                          );
                        } else return CircularProgressIndicator();
                      }
                  ),
                ]
              ),
              SizedBox(height: 15,),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettings()));
                },
                child: Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(10)),
                  side: BorderSide( width: 2, color: Colors.grey),
                  fixedSize: Size(350, 35),
                ),

              ),
              const SizedBox(
                height: 40,
              ),
      Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: user?.uid).snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Can not get posts data",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
                  ),
                );
              }

              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    return PostCard(
                      snap: snapshot.data!.docs[index].data(),
                      key: Key(snapshot.data!.docs[index].data()['postId']),
                    );
                  });
            },
          )
        ],
      ),
            ],
          ),
        ),
      ]),
    );
  }
}
