import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioTrainingScreen extends StatefulWidget {
  @override State<AudioTrainingScreen> createState() => _AudioTrainingScreenState();
}

class _AudioTrainingScreenState extends State<AudioTrainingScreen> {
  bool hasAudioPackage = false;
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override void initState() {
    super.initState();
    checkAudioSubscription();
  }

  Future<void> checkAudioSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user!= null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        hasAudioPackage = doc.data()?['hasAudioPackage']?? false;
      });
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('??????? ??????')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('audio_lessons').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length + 1,
            itemBuilder: (context, index) {
              if (index == snapshot.data!.docs.length) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    ElevatedButton(onPressed: () {}, child: Text('???? ???')),
                    SizedBox(height: 10),
                    ElevatedButton(onPressed: () => showAdDialog(context), child: Text('????? ?????'))
                  ])
                );
              }
              var lesson = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(lesson['title']),
                  subtitle: Text(lesson['sentence']),
                  trailing: hasAudioPackage? IconButton(icon: Icon(Icons.mic), onPressed: () => checkPronunciation(lesson['sentence'])) : null,
                  onTap: () => playAudio(lesson['audio_url'], showMidAd:!hasAudioPackage)
                )
              );
            }
          );
        }
      )
    );
  }

  void playAudio(String url, {required bool showMidAd}) {
    _audioPlayer.play(UrlSource(url));
    if (showMidAd) {
      Future.delayed(Duration(seconds: 10), () {
        _audioPlayer.pause();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('????? - ????????? ???? ???????')));
        Future.delayed(Duration(seconds: 5), () => _audioPlayer.resume());
      });
    }
  }

  void checkPronunciation(String sentence) async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        String spoken = result.recognizedWords.toLowerCase();
        bool correct = spoken.contains(sentence.toLowerCase());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(correct? '????!' : '???? ????')));
      });
    }
  }

  void showAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('????? ?????'),
        content: Text('?????: 50 ????. ?? ????? ??? ???????'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('ads').add({
                'status': 'pending',
                'user': FirebaseAuth.instance.currentUser!.uid
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('?? ????? ??????? ????????')));
            },
            child: Text('?????')
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('?????'))
        ]
      )
    );
  }
}
