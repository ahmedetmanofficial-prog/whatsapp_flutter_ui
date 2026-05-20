import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class VideosScreen extends StatefulWidget {
  @override State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  bool hasVideoPackage = false;

  @override void initState() {
    super.initState();
    checkVideoSubscription();
  }

  Future<void> checkVideoSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user!= null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        hasVideoPackage = doc.data()?['hasVideoPackage']?? false;
      });
    }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('??????????')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('videos').orderBy('order').snapshots(),
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
              var video = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(video['title']),
                  subtitle: Text(video['description']),
                  onTap: () => playVideo(video['url'], showMidAd:!hasVideoPackage)
                )
              );
            }
          );
        }
      )
    );
  }

  void playVideo(String url, {required bool showMidAd}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 200,
          child: VideoPlayerWidget(url: url, showAd: showMidAd)
        )
      )
    );
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

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool showAd;
  VideoPlayerWidget({required this.url, required this.showAd});
  @override State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
   ..initialize().then((_) {
        setState(() {});
        _controller.play();
        if (widget.showAd) {
          Future.delayed(Duration(seconds: 10), () {
            _controller.pause();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('????? - ????????? ???? ???????')));
            Future.delayed(Duration(seconds: 5), () => _controller.play());
          });
        }
      });
  }

  @override Widget build(BuildContext context) {
    return _controller.value.isInitialized
   ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
     : Center(child: CircularProgressIndicator());
  }

  @override void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
