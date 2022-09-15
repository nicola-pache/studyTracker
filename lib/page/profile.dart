import 'package:flutter/material.dart';
import 'package:untitled/page/accessibility.dart';
import 'package:untitled/page/privacy.dart';
import 'package:untitled/page/settings.dart';
import 'impressum.dart';
import 'feedback.dart';

/// This class builds the profile page.
class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  /// Builds the profile.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil")
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 10.0),
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 50,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 15),
          Card(
            child: ListTile(
                leading: Icon(Icons.settings),
                title: Text("Einstellungen", style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return Settings();
                      }));
                }
            )
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.accessibility),
              title: Text("Barrierefreiheit", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return Accessibility();
                    }));
              }
            )
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("Impressum", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return Impressum();
                }));
              }
            )
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.security),
              title: Text("Datenschutz", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context){
                  return Privacy();
                }));
              }
            )
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.alternate_email),
              title: Text("Feedback", style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) {
                  return FeedbackST();
                }));
              }
            )
          )
        ]
      )
    );
  }
}
