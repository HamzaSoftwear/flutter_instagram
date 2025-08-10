// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/screens/profile.dart';
import 'package:flutter_instagram/shared/colors.dart';


class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    myController.addListener(showUser);
  }

  showUser() {
    setState(() {});
  }

  @override
  void dispose() {
    myController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mobileBackgroundColor,
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextFormField(
            // onChanged: (value) {
            //   setState(() {});
            // },
            controller: myController,
            decoration:
                const InputDecoration(labelText: 'Search for a user...'),
          ),
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('userSSS')
              .where("username", isEqualTo: myController.text)
              .get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Profile(
                                    uiddd: snapshot.data!.docs[index]["uid"],
                                  )),
                        );
                      },
                      title: Text(snapshot.data!.docs[index]["username"] ?? "Unknown User"),
                      leading: CircleAvatar(
                        radius: 33,
                        backgroundImage: (snapshot.data!.docs[index]["profileImg"] != null && snapshot.data!.docs[index]["profileImg"].isNotEmpty)
                            ? NetworkImage(snapshot.data!.docs[index]["profileImg"])
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: (snapshot.data!.docs[index]["profileImg"] == null || snapshot.data!.docs[index]["profileImg"].isEmpty)
                            ? Icon(
                                Icons.person,
                                size: 33,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                    );
                  });
            }

            return Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          },
        ));
  }
}