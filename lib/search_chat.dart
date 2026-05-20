import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SearchChatScreen extends StatefulWidget {
  @override State<SearchChatScreen> createState() => _SearchChatScreenState();
}

class _SearchChatScreenState extends State<SearchChatScreen> {
  bool hasSearchPackage = false;
  int freeQuestions = 3;
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  List<Map<String, String>> messages = [];

  @override void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user!= null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        hasSearchPackage = doc.data()?['hasSearchPackage']?? false;
        freeQuestions = doc.data()?['freeQuestions']?? 3;
      });
    }
  }

  Future<void> getAnswer(String arabicText) async {
    if (!hasSearchPackage && freeQuestions <= 0) {
      showPaywall();
      return;
    }

    // ??? ????? ????? AI ?????? ?????? ????? ???????
    String englishAnswer = "Translation + Answer for: $arabicText";
    String arabicAnswer = "??????? ??????? ??????: $arabicText";

    setState(() {
      messages.add({'ar': arabicAnswer, 'en': englishAnswer});
    });

    // ?? ?? ?????? ??? ???? ?????
    if (!hasSearchPackage) {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'freeQuestions': FieldValue.increment(-1)
      });
      setState(() {
        freeQuestions--;
      });
    }
  }

  void speak(String text) async {
    await _tts.setLanguage("en-US");
    await _tts.speak(text);
  }

  void showPaywall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('???? ?????? ????????'),
        content: Text('????? ?? 100 ???? ????? ???? ???? ??????'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('????? ????')),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('?????'))
        ]
      )
    );
  }

  @override Widget build(BuildContext context) {
    if (!hasSearchPackage && freeQuestions <= 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text('???? ?????? ????????'),
            ElevatedButton(onPressed: showPaywall, child: Text('????? ????'))
          ]
        )
      );
    }

    return Column(
      children: [
        if (!hasSearchPackage)
          Container(
            color: Colors.amber[100],
            padding: EdgeInsets.all(10),
            child: Text('????? ??: $freeQuestions ????? ??????')
          ),
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('????: ${messages[index]['ar']}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: Text('English: ${messages[index]['en']}', style: TextStyle(fontSize: 16))),
                          IconButton(
                            icon: Icon(Icons.volume_up),
                            onPressed: () => speak(messages[index]['en']!)
                          )
                        ]
                      )
                    ]
                  )
                )
              );
            }
          )
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: '???? ????? ???????...')
                )
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    getAnswer(_controller.text);
                    _controller.clear();
                  }
                }
              )
            ]
          )
        )
      ]
    );
  }
}
