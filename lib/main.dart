import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_constants.dart';
import 'firebase_options.dart';
import 'database_helper.dart';
import 'quote.dart';
import 'api_service.dart';
import 'firestore_diary.dart';
import 'login_page.dart';
import 'travel_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    firebaseError = error;
  }
  runApp(MyApp(firebaseError: firebaseError));
}

class MyApp extends StatelessWidget {
  final Object? firebaseError;

  const MyApp({super.key, this.firebaseError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: TravelColors.teal)
            .copyWith(
              primary: TravelColors.teal,
              secondary: TravelColors.coral,
              surface: Colors.white,
              onSurface: TravelColors.ink,
            ),
        scaffoldBackgroundColor: TravelColors.canvas,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: TravelColors.canvas,
          foregroundColor: TravelColors.ink,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: TravelColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFDCE8E4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFDCE8E4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: TravelColors.teal, width: 1.8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: TravelColors.deepTeal.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEAF0ED)),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: TravelColors.paleTeal,
          elevation: 8,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? TravelColors.deepTeal : Colors.blueGrey,
            );
          }),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: TravelColors.coral,
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: firebaseError == null
          ? AuthGate(authenticatedBuilder: (_) => const MainPage())
          : FirebaseSetupPage(error: firebaseError!),
    );
  }
}

class FirebaseSetupPage extends StatelessWidget {
  final Object error;

  const FirebaseSetupPage({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า Firebase')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'ยังเชื่อมต่อ Firebase ไม่ได้\n'
                'ตั้งค่าโปรเจกต์ด้วย FlutterFire CLI แล้วลองเปิดแอปอีกครั้ง',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === หน้าหลัก + เมนูล่าง ===
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DiaryListPage(), // แท็บ SQLite (เครื่อง)
    const ApiDiaryPage(), // แท็บ REST API (ออนไลน์)
    const FirestoreDiaryPage(), // แท็บ Firebase (Cloud)
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book_rounded),
            label: 'ทริปในเครื่อง',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'ทริปออนไลน์',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud_done),
            label: 'ทริปของฉัน',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'เกี่ยวกับ',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🔹 แท็บที่ 1: เครื่อง (SQLite)
// ==========================================
class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Diary> diaries = [];
  Quote? qoute;
  String _searchQuery = '';
  late Future<Quote> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = ApiService.fetchQuote();
    _loadDiaries();
  }

  Future<void> _loadDiaries() async {
    final data = await DatabaseHelper.getAll();
    setState(() {
      diaries = data;
    });
  }

  Future<void> _addDiary(Diary diary) async {
    await DatabaseHelper.insert(diary);
    _loadDiaries();
  }

  Future<void> _updateDiary(Diary diary) async {
    await DatabaseHelper.update(diary);
    _loadDiaries();
  }

  Future<void> _deleteDiary(int id) async {
    await DatabaseHelper.delete(id);
    _loadDiaries();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.green,
    ];
    final filteredDiaries = diaries.where((diary) {
      return matchesTravelSearch([
        diary.title,
        diary.content,
        diary.mood,
        diary.date,
      ], _searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('ทริปในเครื่อง (${diaries.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _quoteFuture = ApiService.fetchQuote();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // กล่องคำคม
          FutureBuilder<Quote>(
            future: _quoteFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'กำลังโหลดคำคม...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'โหลดคำคมไม่ได้',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _quoteFuture = ApiService.fetchQuote();
                          });
                        },
                        child: const Text('ลองใหม่'),
                      ),
                    ],
                  ),
                );
              } else {
                final quote = snapshot.data!;
                qoute = quote;
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [TravelColors.deepTeal, TravelColors.teal],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: TravelColors.deepTeal.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        color: Color(0xFFFFB39F),
                        size: 28,
                      ),
                      Text(
                        '"${quote.text}"',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— ${quote.author}',
                        style: const TextStyle(
                          color: Color(0xFFBDEBE1),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          TravelSearchField(
            onChanged: (query) => setState(() => _searchQuery = query),
          ),
          TravelCountCard(
            count: _searchQuery.trim().isEmpty
                ? diaries.length
                : filteredDiaries.length,
            label: _searchQuery.trim().isEmpty
                ? 'ทริปที่บันทึกในเครื่อง'
                : 'ผลการค้นหา',
          ),
          // รายการบันทึก
          Expanded(
            child: filteredDiaries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.luggage_outlined
                              : Icons.search_off_rounded,
                          size: 72,
                          color: TravelColors.teal.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'ยังไม่มีทริปที่บันทึกไว้'
                              : 'ไม่พบทริปที่ตรงกับคำค้นหา',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: TravelColors.ink,
                          ),
                        ),
                        if (_searchQuery.isEmpty)
                          const Text(
                            'กดปุ่ม + เพื่อเพิ่มทริปแรก',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: filteredDiaries.length,
                    itemBuilder: (context, i) {
                      final diary = filteredDiaries[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: TravelColors.paleTeal,
                            child: Icon(
                              Icons.flight_outlined,
                              color: colors[i % colors.length],
                            ),
                          ),
                          title: Text(
                            diary.title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${diary.date} • ${diary.mood} • ${diary.content}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddDiaryPage(existing: diary),
                                    ),
                                  );
                                  if (result != null && result is Diary) {
                                    await _updateDiary(result);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('ลบทริป?'),
                                      content: Text(
                                        'ต้องการลบทริป "${diary.title}" ใช่ไหม',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('ยกเลิก'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text(
                                            'ลบ',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    _deleteDiary(diary.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DiaryDetailPage(diary: diary),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDiaryPage(qoute: qoute)),
          );
          if (result != null && result is Diary) {
            _addDiary(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// 🔹 แท็บที่ 2: ออนไลน์ (ApiDiaryPage) - REST API + Lab 4 Catch Error
// ==========================================
class ApiDiaryPage extends StatefulWidget {
  const ApiDiaryPage({super.key});

  @override
  State<ApiDiaryPage> createState() => _ApiDiaryPageState();
}

class _ApiDiaryPageState extends State<ApiDiaryPage> {
  late Future<List<dynamic>> _diariesFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  void _loadDiaries() {
    setState(() {
      _diariesFuture = ApiService.getDiaries();
    });
  }

  // --- Lab 4: Catch Error เน็ตหลุด / Server มีปัญหา ---
  Future<void> _addDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    try {
      await ApiService.createDiary(title, content, mood, date);
      _loadDiaries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต')),
        );
      }
    }
  }

  Future<void> _updateDiary(
    String id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    try {
      await ApiService.updateDiary(id, title, content, mood, date);
      _loadDiaries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('แก้ไขไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต')),
        );
      }
    }
  }

  Future<void> _deleteDiary(String id) async {
    try {
      await ApiService.deleteDiary(id);
      _loadDiaries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ทริปออนไลน์ (REST API)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadDiaries),
        ],
      ),
      body: Column(
        children: [
          const TravelHero(
            eyebrow: 'จุดหมายต่อไป',
            title: 'โลกกว้างรออยู่',
            subtitle: 'จัดเก็บแผนเที่ยวไว้บน REST API',
            icon: Icons.public,
            badge: 'ONLINE  •  REST API',
          ),
          TravelSearchField(
            onChanged: (query) => setState(() => _searchQuery = query),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _diariesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 56,
                            color: TravelColors.teal,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'เชื่อมต่อทริปออนไลน์ไม่ได้\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _loadDiaries,
                            icon: const Icon(Icons.refresh),
                            label: const Text('ลองเชื่อมต่ออีกครั้ง'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final diaries = snapshot.data!;
                final filteredDiaries = diaries.where((diary) {
                  return matchesTravelSearch([
                    diary['title']?.toString(),
                    diary['content']?.toString(),
                    diary['mood']?.toString(),
                    diary['date']?.toString(),
                  ], _searchQuery);
                }).toList();
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 2, bottom: 92),
                  itemCount: filteredDiaries.isEmpty
                      ? 2
                      : filteredDiaries.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return TravelCountCard(
                        count: filteredDiaries.length,
                        label: _searchQuery.trim().isEmpty
                            ? 'ทริปทั้งหมด'
                            : 'ผลการค้นหา',
                      );
                    }
                    if (filteredDiaries.isEmpty) {
                      return SizedBox(
                        height: 240,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _searchQuery.trim().isEmpty
                                    ? Icons.luggage_outlined
                                    : Icons.search_off_rounded,
                                size: 68,
                                color: TravelColors.teal.withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.trim().isEmpty
                                    ? 'ยังไม่มีทริปออนไลน์'
                                    : 'ไม่พบทริปที่ตรงกับคำค้นหา',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: TravelColors.ink,
                                ),
                              ),
                              if (_searchQuery.trim().isEmpty)
                                const Text(
                                  'แตะปุ่ม + เพื่อวางแผนการเดินทาง',
                                  style: TextStyle(color: Colors.blueGrey),
                                ),
                            ],
                          ),
                        ),
                      );
                    }
                    final obj = filteredDiaries[i - 1];
                    final String id =
                        obj['id']?.toString() ?? obj['_id']?.toString() ?? '';

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: TravelColors.paleTeal,
                          child: Icon(
                            Icons.flight_outlined,
                            color: TravelColors.teal,
                          ),
                        ),
                        title: Text(
                          obj['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${obj['mood'] ?? ''} • ${obj['date'] ?? ''}\n${obj['content'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'แก้ไขทริป',
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: TravelColors.teal,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ApiFormPage(existing: obj),
                                  ),
                                );
                                if (result is Map) {
                                  await _updateDiary(
                                    id,
                                    result['title'],
                                    result['content'],
                                    result['mood'],
                                    result['date'],
                                  );
                                }
                              },
                            ),
                            IconButton(
                              tooltip: 'ลบทริป',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: TravelColors.coral,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('ลบทริป?'),
                                    content: Text(
                                      'ต้องการลบทริป "${obj['title']}" ใช่ไหม',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('ยกเลิก'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          'ลบ',
                                          style: TextStyle(
                                            color: TravelColors.coral,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) await _deleteDiary(id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApiFormPage()),
          );
          if (result is Map) {
            await _addDiary(
              result['title'],
              result['content'],
              result['mood'],
              result['date'],
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// 🔹 ฟอร์มเพิ่ม/แก้ไข บันทึกบน Server (ApiFormPage)
// ==========================================
class ApiFormPage extends StatefulWidget {
  final Map? existing;
  const ApiFormPage({super.key, this.existing});

  @override
  State<ApiFormPage> createState() => _ApiFormPageState();
}

class _ApiFormPageState extends State<ApiFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _mood = 'มีความสุข';
  final List<String> _moods = [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
  ];
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!['title'] ?? '';
      _contentController.text = widget.existing!['content'] ?? '';
      _mood = widget.existing!['mood'] ?? 'มีความสุข';
      _date =
          DateTime.tryParse(widget.existing!['date'] ?? '') ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'เพิ่มทริปออนไลน์' : 'แก้ไขทริปออนไลน์',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ประเทศหรือชื่อสถานที่',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'กรุณากรอกประเทศหรือชื่อสถานที่'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียดหรือแผนการเดินทาง',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'กรุณากรอกรายละเอียดการเดินทาง'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _mood,
                  decoration: const InputDecoration(
                    labelText: 'ความรู้สึกระหว่างทริป',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _mood = v!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('วันที่: ${_date.toString().substring(0, 10)}'),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'title': _titleController.text.trim(),
                          'content': _contentController.text.trim(),
                          'mood': _mood,
                          'date': _date.toString().substring(0, 10),
                        });
                      }
                    },
                    child: const Text('บันทึกทริป'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🔹 หน้ารายละเอียดบันทึก (เครื่อง)
// ==========================================
class DiaryDetailPage extends StatelessWidget {
  final Diary diary;
  const DiaryDetailPage({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียด')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              diary.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (diary.qoute != null && diary.qoute!.isNotEmpty)
              Text(
                diary.qoute!,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              diary.date,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Chip(
              avatar: const Icon(Icons.mood, size: 18),
              label: Text(diary.mood),
            ),
            const Divider(height: 32),
            Text(
              diary.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 🔹 หน้าเกี่ยวกับ (AboutPage)
// ==========================================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับ')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [TravelColors.deepTeal, TravelColors.teal],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Icon(
                        Icons.travel_explore_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      appName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFE1F4EF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: TravelColors.paleTeal,
                    child: Icon(Icons.person_outline, color: TravelColors.teal),
                  ),
                  title: Text(
                    'ผู้พัฒนา',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                  ),
                  subtitle: Text(
                    'ยุทธศาสตร์ • 66011212040',
                    style: TextStyle(
                      color: TravelColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'เวอร์ชัน 1.0',
                style: TextStyle(color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 🔹 หน้าเขียนบันทึกใหม่ (เครื่อง)
// ==========================================
class AddDiaryPage extends StatefulWidget {
  final Diary? existing;
  final Quote? qoute;
  const AddDiaryPage({super.key, this.existing, this.qoute});

  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'มีความสุข';
  final List<String> _moods = [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
  ];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _contentController.text = widget.existing!.content;
      _selectedMood = widget.existing!.mood;
      _selectedDate = DateTime.parse(widget.existing!.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'เพิ่มทริปในเครื่อง' : 'แก้ไขทริป',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ประเทศหรือชื่อสถานที่',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกประเทศหรือชื่อสถานที่';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียดหรือแผนการเดินทาง',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกรายละเอียดการเดินทาง';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if ((widget.existing?.qoute ?? widget.qoute?.text) != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'คำคมที่จะบันทึก: "${widget.existing?.qoute ?? widget.qoute?.text}"',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                DropdownButtonFormField<String>(
                  value: _selectedMood,
                  decoration: const InputDecoration(
                    labelText: 'ความรู้สึกระหว่างทริป',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods.map((mood) {
                    return DropdownMenuItem(value: mood, child: Text(mood));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMood = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'วันที่: ${_selectedDate.toString().substring(0, 10)}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newDiary = Diary(
                          id: widget.existing?.id,
                          title: _titleController.text.trim(),
                          content: _contentController.text.trim(),
                          date: _selectedDate.toString().substring(0, 10),
                          mood: _selectedMood,
                          qoute: widget.existing?.qoute ?? widget.qoute?.text,
                        );
                        Navigator.pop(context, newDiary);
                      }
                    },
                    child: const Text('บันทึกทริป'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
