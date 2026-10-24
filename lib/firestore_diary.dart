import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firestore_service.dart';
import 'travel_widgets.dart';

class FirestoreDiaryPage extends StatelessWidget {
  const FirestoreDiaryPage({super.key});

  Future<void> _showError(BuildContext context, Object error) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('บันทึกข้อมูลทริปไม่สำเร็จ: $error')),
    );
  }

  Future<void> _deleteDiary(
    BuildContext context,
    String docId,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ลบทริป?'),
        content: Text('ต้องการลบทริป "$title" ใช่ไหม'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await FirestoreService.delete(docId);
    } catch (error) {
      if (context.mounted) await _showError(context, error);
    }
  }

  Future<void> _openForm(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? existing,
  }) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => FirestoreFormPage(existing: existing)),
    );
    if (result == null || !context.mounted) return;

    try {
      if (docId == null) {
        await FirestoreService.add(
          result['title']!,
          result['content']!,
          result['date']!,
          result['mood']!,
        );
      } else {
        await FirestoreService.update(
          docId,
          result['title']!,
          result['content']!,
          result['date']!,
          result['mood']!,
        );
      }
    } catch (error) {
      if (context.mounted) await _showError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ทริปต่างประเทศของฉัน'),
        actions: [
          IconButton(
            tooltip: 'ออกจากระบบ',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (error) {
                if (context.mounted) await _showError(context, error);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const TravelHero(
            eyebrow: 'เก็บทุกความทรงจำ',
            title: 'ทริปของคุณ',
            subtitle: 'ซิงก์แผนเดินทางไว้บน Cloud',
            icon: Icons.cloud_done_outlined,
            badge: 'PRIVATE  •  FIRESTORE',
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirestoreService.getMyDiaries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_outlined,
                            size: 52,
                            color: TravelColors.teal,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'โหลดข้อมูลทริปไม่สำเร็จ\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flight_takeoff_rounded,
                          size: 68,
                          color: TravelColors.teal.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'ยังไม่มีทริปที่บันทึกไว้',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: TravelColors.ink,
                          ),
                        ),
                        const Text(
                          'แตะปุ่ม + เพื่อเริ่มวางแผนทริปแรก',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 2, bottom: 92),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final title = data['title'] as String? ?? '';
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
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${data['date'] ?? ''} • ${data['mood'] ?? 'ยังไม่ระบุอารมณ์'} • ${data['content'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () =>
                            _openForm(context, docId: doc.id, existing: data),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'แก้ไขข้อมูลทริป',
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: TravelColors.teal,
                              ),
                              onPressed: () => _openForm(
                                context,
                                docId: doc.id,
                                existing: data,
                              ),
                            ),
                            IconButton(
                              tooltip: 'ลบทริป',
                              icon: const Icon(
                                Icons.delete_outline,
                                color: TravelColors.coral,
                              ),
                              onPressed: () =>
                                  _deleteDiary(context, doc.id, title),
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
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FirestoreFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const FirestoreFormPage({super.key, this.existing});

  @override
  State<FirestoreFormPage> createState() => _FirestoreFormPageState();
}

class _FirestoreFormPageState extends State<FirestoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMood = 'มีความสุข';
  static const _moods = ['มีความสุข', 'เฉยๆ', 'เศร้า', 'เหนื่อย', 'ตื่นเต้น'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing['title'] as String? ?? '';
      _contentController.text = existing['content'] as String? ?? '';
      _selectedDate =
          DateTime.tryParse(existing['date'] as String? ?? '') ??
          DateTime.now();
      final mood = existing['mood'] as String?;
      if (mood != null && _moods.contains(mood)) {
        _selectedMood = mood;
      }
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
    final date = _selectedDate.toString().substring(0, 10);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'เพิ่มทริปต่างประเทศ' : 'แก้ไขทริป',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'ประเทศหรือชื่อสถานที่',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
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
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'กรุณากรอกรายละเอียดการเดินทาง'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMood,
                decoration: const InputDecoration(
                  labelText: 'ความรู้สึกระหว่างทริป',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.mood),
                ),
                items: _moods
                    .map(
                      (mood) =>
                          DropdownMenuItem(value: mood, child: Text(mood)),
                    )
                    .toList(),
                onChanged: (mood) {
                  if (mood != null) setState(() => _selectedMood = mood);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('วันที่: $date'),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    Navigator.pop(context, {
                      'title': _titleController.text.trim(),
                      'content': _contentController.text.trim(),
                      'date': _selectedDate.toString().substring(0, 10),
                      'mood': _selectedMood,
                    });
                  },
                  child: Text(
                    widget.existing == null ? 'เพิ่มทริป' : 'บันทึกการแก้ไข',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
