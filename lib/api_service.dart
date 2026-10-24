import 'dart:convert';
import 'package:http/http.dart' as http;
import 'quote.dart';

class ApiService {
  // ⚠️ เปลี่ยน studentId เป็นรหัสนักศึกษาของคุณ
  static const String studentId = '66011212040';
  static const String baseUrl =
      'https://thipwimon.comsciproject.net/mydiary/api.php/$studentId';

  // --- ดึงคำคมประจำวัน (สัปดาห์ 3) ---
  static Future<Quote> fetchQuote() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/quotes/random'),
    );
    if (response.statusCode == 200) {
      return Quote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('โหลดคำคมไม่สำเร็จ');
    }
  }

  // --- CREATE: เพิ่มบันทึก (POST) ---
  static Future<void> createDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'mood': mood,
        'date': date,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('เพิ่มไม่สำเร็จ (${response.statusCode})');
    }
  }

  // --- READ: อ่านบันทึกทั้งหมด (GET) ---
  static Future<List<dynamic>> getDiaries() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> all = jsonDecode(response.body);
      return all;
    }
    throw Exception('โหลดไม่สำเร็จ (${response.statusCode})');
  }

  // --- UPDATE: แก้ไขบันทึก (PUT) ---
  static Future<void> updateDiary(
    String id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'mood': mood,
        'date': date,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('แก้ไขไม่สำเร็จ (${response.statusCode})');
    }
  }

  // --- DELETE: ลบบันทึก (DELETE) ---
  static Future<void> deleteDiary(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('ลบไม่สำเร็จ (${response.statusCode})');
    }
  }
}
