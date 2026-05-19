import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

enum UserRole { admin, visitor, user }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Learning App',
      theme: ThemeData(primaryColor: Color(0xFF075E54), useMaterial3: true),
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
  UserRole currentRole = UserRole.visitor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this, initialIndex: 7);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('English Learning'),
        backgroundColor: Color(0xFF075E54),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'مكالمات Video'),
            Tab(text: 'مكالمات Audio'),
            Tab(text: 'فيديوهات'),
            Tab(text: 'القصص'),
            Tab(text: 'الدردشات'),
            Tab(text: 'البحث'),
            Tab(text: 'الشهادات'),
            Tab(text: 'أنا'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CallsTab(type: 'video', role: currentRole, room: 'room_video_3'),
          CallsTab(type: 'audio', role: currentRole, room: 'room_audio_3'),
          VideosTab(role: currentRole),
          StoriesTab(role: currentRole),
          ChatsTab(role: currentRole, room: 'room_chat_3'),
          SearchTab(role: currentRole),
          CertificatesTab(),
          ProfileTab(role: currentRole, onRoleChange: (r) => setState(() => currentRole = r)),
        ],
      ),
    );
  }
}

class CallsTab extends StatelessWidget {
  final String type;
  final UserRole role;
  final String room;

  CallsTab({required this.type, required this.role, required this.room});

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.visitor) {
      return Center(child: Text('المكالمات للمشتركين فقط'));
    }
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(type == 'video'? 'مكالمات الفيديو' : 'مكالمات الصوت', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Card(
          color: Colors.orange[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('جرب بـ 15 دقيقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800])),
              SizedBox(height: 10),
              Text('5 غرف متاحة'),
              SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: Text('ادخل غرفة تجريبية')),
            ]),
          ),
        ),
        SizedBox(height: 20),
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('نظامك - ساعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800])),
              SizedBox(height: 10),
              Text('غرفتك: $room'),
              SizedBox(height: 10),
              ElevatedButton(onPressed: () {}, child: Text('ادخل غرفتك الآن')),
            ]),
          ),
        ),
        ContactUs(),
      ],
    );
  }
}

class VideosTab extends StatelessWidget {
  final UserRole role;
  VideosTab({required this.role});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(leading: Icon(Icons.play_circle, color: Colors.red), title: Text('فيديو تعليمي 1'), subtitle: Text('أساسيات المحادثة')),
        Divider(),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            Text('مكان الإعلانات', style: TextStyle(color: Colors.orange)),
            SizedBox(height: 10),
            ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.ads_click), label: Text('اطلب إعلان'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
          ]),
        ),
        ContactUs(),
      ],
    );
  }
}

class StoriesTab extends StatelessWidget {
  final UserRole role;
  StoriesTab({required this.role});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text('قصة 1: في المطعم'),
          trailing: role!= UserRole.visitor? IconButton(icon: Icon(Icons.volume_up), onPressed: () {}) : Icon(Icons.lock, color: Colors.grey),
        ),
        Divider(),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(children: [
            Text('مكان الإعلانات', style: TextStyle(color: Colors.orange)),
            SizedBox(height: 10),
            ElevatedButton.icon(onPressed: () {}, icon: Icon(Icons.ads_click), label: Text('اطلب إعلان'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
          ]),
        ),
        ContactUs(),
      ],
    );
  }
}

class ChatsTab extends StatelessWidget {
  final UserRole role;
  final String room;
  ChatsTab({required this.role, required this.room});

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.visitor) {
      return Center(child: Text('الدردشات للمشتركين فقط'));
    }
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.chat, size: 80, color: Color(0xFF075E54)),
        SizedBox(height: 20),
        Text('غرفتك: $room'),
        Text('ريكورد صوتي فقط - ساعة يومياً'),
      ]),
    );
  }
}

class SearchTab extends StatelessWidget {
  final UserRole role;
  SearchTab({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.visitor) {
      return Center(child: Text('البحث للمشتركين فقط'));
    }
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(children: [
        TextField(decoration: InputDecoration(hintText: 'ابحث بالعربي...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
        SizedBox(height: 20),
        Text('النتيجة هتظهر هنا عربي + انجليزي + سماعة'),
        ContactUs(),
      ]),
    );
  }
}

class CertificatesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.card_membership, size: 80, color: Color(0xFF075E54)),
        SizedBox(height: 20),
        Text('احصل على شهادتك في 10 أيام'),
        SizedBox(height: 30),
        ElevatedButton(onPressed: () {}, child: Text('اطلب الشهادة')),
        ContactUs(),
      ]),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final UserRole role;
  final Function(UserRole) onRoleChange;
  ProfileTab({required this.role, required this.onRoleChange});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.person, size: 80, color: Color(0xFF075E54)),
          SizedBox(height: 20),
          Text('نوع الحساب', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 30),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: Size(double.infinity, 50)), onPressed: () => onRoleChange(UserRole.admin), child: Text('دخول كأدمن')),
          SizedBox(height: 15),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)), onPressed: () => onRoleChange(UserRole.visitor), child: Text('دخول كزائر')),
          SizedBox(height: 15),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF25D366), minimumSize: Size(double.infinity, 50)), onPressed: () => onRoleChange(UserRole.user), child: Text('دخول كمستخدم')),
        ]),
      ),
    );
  }
}

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextButton.icon(onPressed: () {}, icon: Icon(Icons.contact_support), label: Text('اتصل بنا')),
    );
  }
}