import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTrainingScreen extends StatefulWidget {
  @override
  State<LiveTrainingScreen> createState() => _LiveTrainingScreenState();
}

class _LiveTrainingScreenState extends State<LiveTrainingScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? roomId;
  bool isTrainer = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> createRoom() async {
    final user = FirebaseAuth.instance.currentUser!;
    roomId = FirebaseFirestore.instance.collection('rooms').doc().id;
    
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });
    _localRenderer.srcObject = _localStream;

    Map<String, dynamic> configuration = {
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}]
    };
    
    _peerConnection = await createPeerConnection(configuration);
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    await FirebaseFirestore.instance.collection('rooms').doc(roomId).set({
      'trainerId': user.uid,
      'participants': [user.uid],
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true
    });

    setState(() {
      isTrainer = true;
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('التدريب المباشر')),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                Expanded(child: RTCVideoView(_remoteRenderer)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: createRoom,
              child: Text('ابدأ غرفة مباشر'),
            ),
          )
        ],
      ),
    );
  }
}
