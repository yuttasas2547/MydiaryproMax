# ท่องเที่ยวต่างประเทศ

แอปวางแผนและบันทึกการเดินทางต่างประเทศ สามารถสร้างบัญชีและเข้าสู่ระบบด้วยอีเมล
บันทึกแผนทริปของตัวเองไว้บน Firebase Cloud Firestore และดูข้อมูลได้เมื่อ
เข้าสู่ระบบจากอุปกรณ์อื่น

## ฟีเจอร์

- สมัครสมาชิก เข้าสู่ระบบ และออกจากระบบด้วย Email/Password
- เพิ่ม แก้ไข และลบทริป พร้อมประเทศ/สถานที่ รายละเอียด วันที่ และความรู้สึกระหว่างทริป
- เลือกบันทึกในเครื่องด้วย SQLite หรือจัดการข้อมูลผ่าน REST API
- ซิงก์ข้อมูลทริปแบบเรียลไทม์ผ่าน Cloud Firestore
- แยกข้อมูลของผู้ใช้แต่ละคน และป้องกันการเข้าถึงด้วย Firestore Security Rules
- แสดงคำคมสร้างแรงบันดาลใจขณะวางแผนการเดินทาง

REST API และคำคมต้องใช้อินเทอร์เน็ต ส่วนข้อมูล SQLite ใช้งานในเครื่อง

## การตั้งค่า Firebase

แอปเชื่อมกับ Firebase project `diary5-7c423` สำหรับ Android แล้ว ตรวจสอบว่า
เปิด Email/Password Authentication, สร้าง Firestore `(default)` และ Publish
กฎจาก [firestore.rules](firestore.rules) ใน Firebase Console แล้ว

หากต้องสร้างไฟล์ตั้งค่าใหม่:

```powershell
dart pub global run flutterfire_cli:flutterfire configure --project=diary5-7c423 --platforms=android
```

## ทดสอบและสร้าง APK

ทดสอบบนอุปกรณ์หรือ Emulator ที่เชื่อมต่อ:

```powershell
flutter run --release
```

สร้าง APK สำหรับติดตั้งและแจก:

```powershell
flutter build apk --release
```

ไฟล์ที่ได้อยู่ที่ `build/app/outputs/flutter-apk/app-release.apk`

โอนไฟล์ APK ไปยังมือถือ Android แล้วเปิดติดตั้ง หากมีข้อความเตือน ให้เปิด
อนุญาตติดตั้งแอปจากแหล่งที่ไม่รู้จักสำหรับแอปที่ใช้เปิดไฟล์
Firebase Authentication ต้องการ Android 6.0 (API 23) ขึ้นไป

## ผู้พัฒนา

- ชื่อ: ยุทธศาสตร์
- รหัสนักศึกษา: 66011212040
