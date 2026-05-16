import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Chat App',
      theme: ThemeData(
        primaryColor: Color(0xFF075E54),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF075E54)),
        useMaterial3: true,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF075E54),
        title: Text('English Chat', style: TextStyle(color: Colors.white)),
        actions: [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 20),
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'الدردشات'),
            Tab(text: 'الحالات'),
            Tab(text: 'المكالمات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatsTab(),
          StatusTab(),
          CallsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF25D366),
        onPressed: () {},
        child: Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}

class ChatsTab extends StatelessWidget {
  final List<Map> chats = [
    {'name': 'Group 1', 'msg': 'مرحباً بالجميع', 'time': '10:30'},
    {'name': 'Group 2', 'msg': 'الدرس هيبدأ كمان 5 دقايق', 'time': '09:15'},
    {'name': 'Ahmed Teacher', 'msg': 'تمام، برافو عليك', 'time': 'أمس'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text(chats[index]['name'][0]),
          ),
          title: Text(chats[index]['name'], style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chats[index]['msg']),
          trailing: Text(chats[index]['time'], style: TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {},
        );
      },
    );
  }
}

class StatusTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('قسم الحالات - هنحط الفيديوهات المجانية هنا', style: TextStyle(fontSize: 16)));
  }
}

class CallsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('قسم المكالمات - هنربطه بـ Jitsi هنا', style: TextStyle(fontSize: 16)));
  }
}