import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb

class QuranApiService {
  // Use different endpoints based on platform
  static String get baseUrl {
    return 'https://api.alquran.cloud/v1';
  }
  
  // Available reciters with their IDs
  static final List<QuranReciter> availableReciters = [
    QuranReciter(
      id: 'ar.alafasy',
      name: 'Mishary Rashid Alafasy',
      language: 'Arabic',
    ),
    QuranReciter(
      id: 'ar.abdurrahmaansudais',
      name: 'Abdul Rahman Al-Sudais',
      language: 'Arabic',
    ),
    QuranReciter(
      id: 'ar.saoodshuraym',
      name: 'Saood Al-Shuraym',
      language: 'Arabic',
    ),
    QuranReciter(
      id: 'ar.mahermuaiqly',
      name: 'Maher Al Muaiqly',
      language: 'Arabic',
    ),
    QuranReciter(
      id: 'ar.hudhaify',
      name: 'Ali Al-Hudhaifi',
      language: 'Arabic',
    ),
    QuranReciter(
      id: 'ar.ahmedajamy',
      name: 'Ahmed Al-Ajamy',
      language: 'Arabic',
    ),
  ];

  /// Get list of all surahs
  Future<List<QuranSurah>> getAllSurahs() async {
    try {
      // For web platform, we'll handle CORS issues
      if (kIsWeb) {
        print('🌐 Running on web platform - using fallback data');
        return _getFallbackSurahData();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/surah'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ Request timeout - using fallback data');
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final List<dynamic> surahsData = data['data'];
          return surahsData.map((surah) => QuranSurah.fromJson(surah)).toList();
        }
      }
      
      print('❌ API failed with status ${response.statusCode} - using fallback data');
      return _getFallbackSurahData();
      
    } catch (e) {
      print('❌ Error fetching surahs: $e - using fallback data');
      // Return fallback data instead of throwing error
      return _getFallbackSurahData();
    }
  }

  /// Fallback surah data when API is not accessible
  List<QuranSurah> _getFallbackSurahData() {
    return [
      QuranSurah(number: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', englishNameTranslation: 'The Opening', numberOfAyahs: 7, revelationType: 'Meccan'),
      QuranSurah(number: 2, name: 'البقرة', englishName: 'Al-Baqarah', englishNameTranslation: 'The Cow', numberOfAyahs: 286, revelationType: 'Medinan'),
      QuranSurah(number: 3, name: 'آل عمران', englishName: 'Ali Imran', englishNameTranslation: 'Family of Imran', numberOfAyahs: 200, revelationType: 'Medinan'),
      QuranSurah(number: 4, name: 'النساء', englishName: 'An-Nisa', englishNameTranslation: 'The Women', numberOfAyahs: 176, revelationType: 'Medinan'),
      QuranSurah(number: 5, name: 'المائدة', englishName: 'Al-Maidah', englishNameTranslation: 'The Table', numberOfAyahs: 120, revelationType: 'Medinan'),
      QuranSurah(number: 6, name: 'الأنعام', englishName: 'Al-Anam', englishNameTranslation: 'The Cattle', numberOfAyahs: 165, revelationType: 'Meccan'),
      QuranSurah(number: 7, name: 'الأعراف', englishName: 'Al-Araf', englishNameTranslation: 'The Heights', numberOfAyahs: 206, revelationType: 'Meccan'),
      QuranSurah(number: 8, name: 'الأنفال', englishName: 'Al-Anfal', englishNameTranslation: 'The Spoils of War', numberOfAyahs: 75, revelationType: 'Medinan'),
      QuranSurah(number: 9, name: 'التوبة', englishName: 'At-Tawbah', englishNameTranslation: 'The Repentance', numberOfAyahs: 129, revelationType: 'Medinan'),
      QuranSurah(number: 10, name: 'يونس', englishName: 'Yunus', englishNameTranslation: 'Jonah', numberOfAyahs: 109, revelationType: 'Meccan'),
      QuranSurah(number: 11, name: 'هود', englishName: 'Hud', englishNameTranslation: 'Hud', numberOfAyahs: 123, revelationType: 'Meccan'),
      QuranSurah(number: 12, name: 'يوسف', englishName: 'Yusuf', englishNameTranslation: 'Joseph', numberOfAyahs: 111, revelationType: 'Meccan'),
      QuranSurah(number: 13, name: 'الرعد', englishName: 'Ar-Rad', englishNameTranslation: 'The Thunder', numberOfAyahs: 43, revelationType: 'Medinan'),
      QuranSurah(number: 14, name: 'إبراهيم', englishName: 'Ibrahim', englishNameTranslation: 'Abraham', numberOfAyahs: 52, revelationType: 'Meccan'),
      QuranSurah(number: 15, name: 'الحجر', englishName: 'Al-Hijr', englishNameTranslation: 'The Rocky Tract', numberOfAyahs: 99, revelationType: 'Meccan'),
      QuranSurah(number: 16, name: 'النحل', englishName: 'An-Nahl', englishNameTranslation: 'The Bee', numberOfAyahs: 128, revelationType: 'Meccan'),
      QuranSurah(number: 17, name: 'الإسراء', englishName: 'Al-Isra', englishNameTranslation: 'The Night Journey', numberOfAyahs: 111, revelationType: 'Meccan'),
      QuranSurah(number: 18, name: 'الكهف', englishName: 'Al-Kahf', englishNameTranslation: 'The Cave', numberOfAyahs: 110, revelationType: 'Meccan'),
      QuranSurah(number: 19, name: 'مريم', englishName: 'Maryam', englishNameTranslation: 'Mary', numberOfAyahs: 98, revelationType: 'Meccan'),
      QuranSurah(number: 20, name: 'طه', englishName: 'Taha', englishNameTranslation: 'Ta-Ha', numberOfAyahs: 135, revelationType: 'Meccan'),
      QuranSurah(number: 21, name: 'الأنبياء', englishName: 'Al-Anbya', englishNameTranslation: 'The Prophets', numberOfAyahs: 112, revelationType: 'Meccan'),
      QuranSurah(number: 22, name: 'الحج', englishName: 'Al-Hajj', englishNameTranslation: 'The Pilgrimage', numberOfAyahs: 78, revelationType: 'Medinan'),
      QuranSurah(number: 23, name: 'المؤمنون', englishName: 'Al-Muminun', englishNameTranslation: 'The Believers', numberOfAyahs: 118, revelationType: 'Meccan'),
      QuranSurah(number: 24, name: 'النور', englishName: 'An-Nur', englishNameTranslation: 'The Light', numberOfAyahs: 64, revelationType: 'Medinan'),
      QuranSurah(number: 25, name: 'الفرقان', englishName: 'Al-Furqan', englishNameTranslation: 'The Criterion', numberOfAyahs: 77, revelationType: 'Meccan'),
      QuranSurah(number: 26, name: 'الشعراء', englishName: 'Ash-Shuara', englishNameTranslation: 'The Poets', numberOfAyahs: 227, revelationType: 'Meccan'),
      QuranSurah(number: 27, name: 'النمل', englishName: 'An-Naml', englishNameTranslation: 'The Ant', numberOfAyahs: 93, revelationType: 'Meccan'),
      QuranSurah(number: 28, name: 'القصص', englishName: 'Al-Qasas', englishNameTranslation: 'The Stories', numberOfAyahs: 88, revelationType: 'Meccan'),
      QuranSurah(number: 29, name: 'العنكبوت', englishName: 'Al-Ankabut', englishNameTranslation: 'The Spider', numberOfAyahs: 69, revelationType: 'Meccan'),
      QuranSurah(number: 30, name: 'الروم', englishName: 'Ar-Rum', englishNameTranslation: 'The Romans', numberOfAyahs: 60, revelationType: 'Meccan'),
      QuranSurah(number: 31, name: 'لقمان', englishName: 'Luqman', englishNameTranslation: 'Luqman', numberOfAyahs: 34, revelationType: 'Meccan'),
      QuranSurah(number: 32, name: 'السجدة', englishName: 'As-Sajdah', englishNameTranslation: 'The Prostration', numberOfAyahs: 30, revelationType: 'Meccan'),
      QuranSurah(number: 33, name: 'الأحزاب', englishName: 'Al-Ahzab', englishNameTranslation: 'The Clans', numberOfAyahs: 73, revelationType: 'Medinan'),
      QuranSurah(number: 34, name: 'سبأ', englishName: 'Saba', englishNameTranslation: 'Sheba', numberOfAyahs: 54, revelationType: 'Meccan'),
      QuranSurah(number: 35, name: 'فاطر', englishName: 'Fatir', englishNameTranslation: 'Originator', numberOfAyahs: 45, revelationType: 'Meccan'),
      QuranSurah(number: 36, name: 'يس', englishName: 'Ya-Sin', englishNameTranslation: 'Ya Sin', numberOfAyahs: 83, revelationType: 'Meccan'),
      QuranSurah(number: 37, name: 'الصافات', englishName: 'As-Saffat', englishNameTranslation: 'Those Who Set The Ranks', numberOfAyahs: 182, revelationType: 'Meccan'),
      QuranSurah(number: 38, name: 'ص', englishName: 'Sad', englishNameTranslation: 'The Letter Sad', numberOfAyahs: 88, revelationType: 'Meccan'),
      QuranSurah(number: 39, name: 'الزمر', englishName: 'Az-Zumar', englishNameTranslation: 'The Troops', numberOfAyahs: 75, revelationType: 'Meccan'),
      QuranSurah(number: 40, name: 'غافر', englishName: 'Ghafir', englishNameTranslation: 'The Forgiver', numberOfAyahs: 85, revelationType: 'Meccan'),
      QuranSurah(number: 41, name: 'فصلت', englishName: 'Fussilat', englishNameTranslation: 'Explained In Detail', numberOfAyahs: 54, revelationType: 'Meccan'),
      QuranSurah(number: 42, name: 'الشورى', englishName: 'Ash-Shuraa', englishNameTranslation: 'The Consultation', numberOfAyahs: 53, revelationType: 'Meccan'),
      QuranSurah(number: 43, name: 'الزخرف', englishName: 'Az-Zukhruf', englishNameTranslation: 'The Ornaments Of Gold', numberOfAyahs: 89, revelationType: 'Meccan'),
      QuranSurah(number: 44, name: 'الدخان', englishName: 'Ad-Dukhan', englishNameTranslation: 'The Smoke', numberOfAyahs: 59, revelationType: 'Meccan'),
      QuranSurah(number: 45, name: 'الجاثية', englishName: 'Al-Jathiyah', englishNameTranslation: 'The Crouching', numberOfAyahs: 37, revelationType: 'Meccan'),
      QuranSurah(number: 46, name: 'الأحقاف', englishName: 'Al-Ahqaf', englishNameTranslation: 'The Wind-Curved Sandhills', numberOfAyahs: 35, revelationType: 'Meccan'),
      QuranSurah(number: 47, name: 'محمد', englishName: 'Muhammad', englishNameTranslation: 'Muhammad', numberOfAyahs: 38, revelationType: 'Medinan'),
      QuranSurah(number: 48, name: 'الفتح', englishName: 'Al-Fath', englishNameTranslation: 'The Victory', numberOfAyahs: 29, revelationType: 'Medinan'),
      QuranSurah(number: 49, name: 'الحجرات', englishName: 'Al-Hujurat', englishNameTranslation: 'The Rooms', numberOfAyahs: 18, revelationType: 'Medinan'),
      QuranSurah(number: 50, name: 'ق', englishName: 'Qaf', englishNameTranslation: 'The Letter Qaf', numberOfAyahs: 45, revelationType: 'Meccan'),
      QuranSurah(number: 51, name: 'الذاريات', englishName: 'Adh-Dhariyat', englishNameTranslation: 'The Winnowing Winds', numberOfAyahs: 60, revelationType: 'Meccan'),
      QuranSurah(number: 52, name: 'الطور', englishName: 'At-Tur', englishNameTranslation: 'The Mount', numberOfAyahs: 49, revelationType: 'Meccan'),
      QuranSurah(number: 53, name: 'النجم', englishName: 'An-Najm', englishNameTranslation: 'The Star', numberOfAyahs: 62, revelationType: 'Meccan'),
      QuranSurah(number: 54, name: 'القمر', englishName: 'Al-Qamar', englishNameTranslation: 'The Moon', numberOfAyahs: 55, revelationType: 'Meccan'),
      QuranSurah(number: 55, name: 'الرحمن', englishName: 'Ar-Rahman', englishNameTranslation: 'The Beneficent', numberOfAyahs: 78, revelationType: 'Medinan'),
      QuranSurah(number: 56, name: 'الواقعة', englishName: 'Al-Waqiah', englishNameTranslation: 'The Inevitable', numberOfAyahs: 96, revelationType: 'Meccan'),
      QuranSurah(number: 57, name: 'الحديد', englishName: 'Al-Hadid', englishNameTranslation: 'The Iron', numberOfAyahs: 29, revelationType: 'Medinan'),
      QuranSurah(number: 58, name: 'المجادلة', englishName: 'Al-Mujadalah', englishNameTranslation: 'The Pleading Woman', numberOfAyahs: 22, revelationType: 'Medinan'),
      QuranSurah(number: 59, name: 'الحشر', englishName: 'Al-Hashr', englishNameTranslation: 'The Exile', numberOfAyahs: 24, revelationType: 'Medinan'),
      QuranSurah(number: 60, name: 'الممتحنة', englishName: 'Al-Mumtahanah', englishNameTranslation: 'She That Is To Be Examined', numberOfAyahs: 13, revelationType: 'Medinan'),
      QuranSurah(number: 61, name: 'الصف', englishName: 'As-Saf', englishNameTranslation: 'The Ranks', numberOfAyahs: 14, revelationType: 'Medinan'),
      QuranSurah(number: 62, name: 'الجمعة', englishName: 'Al-Jumuah', englishNameTranslation: 'The Congregation, Friday', numberOfAyahs: 11, revelationType: 'Medinan'),
      QuranSurah(number: 63, name: 'المنافقون', englishName: 'Al-Munafiqun', englishNameTranslation: 'The Hypocrites', numberOfAyahs: 11, revelationType: 'Medinan'),
      QuranSurah(number: 64, name: 'التغابن', englishName: 'At-Taghabun', englishNameTranslation: 'The Mutual Disillusion', numberOfAyahs: 18, revelationType: 'Medinan'),
      QuranSurah(number: 65, name: 'الطلاق', englishName: 'At-Talaq', englishNameTranslation: 'The Divorce', numberOfAyahs: 12, revelationType: 'Medinan'),
      QuranSurah(number: 66, name: 'التحريم', englishName: 'At-Tahrim', englishNameTranslation: 'The Prohibition', numberOfAyahs: 12, revelationType: 'Medinan'),
      QuranSurah(number: 67, name: 'الملك', englishName: 'Al-Mulk', englishNameTranslation: 'The Sovereignty', numberOfAyahs: 30, revelationType: 'Meccan'),
      QuranSurah(number: 68, name: 'القلم', englishName: 'Al-Qalam', englishNameTranslation: 'The Pen', numberOfAyahs: 52, revelationType: 'Meccan'),
      QuranSurah(number: 69, name: 'الحاقة', englishName: 'Al-Haqqah', englishNameTranslation: 'The Reality', numberOfAyahs: 52, revelationType: 'Meccan'),
      QuranSurah(number: 70, name: 'المعارج', englishName: 'Al-Maarij', englishNameTranslation: 'The Ascending Stairways', numberOfAyahs: 44, revelationType: 'Meccan'),
      QuranSurah(number: 71, name: 'نوح', englishName: 'Nuh', englishNameTranslation: 'Noah', numberOfAyahs: 28, revelationType: 'Meccan'),
      QuranSurah(number: 72, name: 'الجن', englishName: 'Al-Jinn', englishNameTranslation: 'The Jinn', numberOfAyahs: 28, revelationType: 'Meccan'),
      QuranSurah(number: 73, name: 'المزمل', englishName: 'Al-Muzzammil', englishNameTranslation: 'The Enshrouded One', numberOfAyahs: 20, revelationType: 'Meccan'),
      QuranSurah(number: 74, name: 'المدثر', englishName: 'Al-Muddaththir', englishNameTranslation: 'The Cloaked One', numberOfAyahs: 56, revelationType: 'Meccan'),
      QuranSurah(number: 75, name: 'القيامة', englishName: 'Al-Qiyamah', englishNameTranslation: 'The Resurrection', numberOfAyahs: 40, revelationType: 'Meccan'),
      QuranSurah(number: 76, name: 'الإنسان', englishName: 'Al-Insan', englishNameTranslation: 'The Man', numberOfAyahs: 31, revelationType: 'Medinan'),
      QuranSurah(number: 77, name: 'المرسلات', englishName: 'Al-Mursalat', englishNameTranslation: 'The Emissaries', numberOfAyahs: 50, revelationType: 'Meccan'),
      QuranSurah(number: 78, name: 'النبأ', englishName: 'An-Naba', englishNameTranslation: 'The Tidings', numberOfAyahs: 40, revelationType: 'Meccan'),
      QuranSurah(number: 79, name: 'النازعات', englishName: 'An-Naziat', englishNameTranslation: 'Those Who Drag Forth', numberOfAyahs: 46, revelationType: 'Meccan'),
      QuranSurah(number: 80, name: 'عبس', englishName: 'Abasa', englishNameTranslation: 'He Frowned', numberOfAyahs: 42, revelationType: 'Meccan'),
      QuranSurah(number: 81, name: 'التكوير', englishName: 'At-Takwir', englishNameTranslation: 'The Overthrowing', numberOfAyahs: 29, revelationType: 'Meccan'),
      QuranSurah(number: 82, name: 'الانفطار', englishName: 'Al-Infitar', englishNameTranslation: 'The Cleaving', numberOfAyahs: 19, revelationType: 'Meccan'),
      QuranSurah(number: 83, name: 'المطففين', englishName: 'Al-Mutaffifin', englishNameTranslation: 'The Defrauding', numberOfAyahs: 36, revelationType: 'Meccan'),
      QuranSurah(number: 84, name: 'الانشقاق', englishName: 'Al-Inshiqaq', englishNameTranslation: 'The Sundering', numberOfAyahs: 25, revelationType: 'Meccan'),
      QuranSurah(number: 85, name: 'البروج', englishName: 'Al-Buruj', englishNameTranslation: 'The Mansions Of The Stars', numberOfAyahs: 22, revelationType: 'Meccan'),
      QuranSurah(number: 86, name: 'الطارق', englishName: 'At-Tariq', englishNameTranslation: 'The Morning Star', numberOfAyahs: 17, revelationType: 'Meccan'),
      QuranSurah(number: 87, name: 'الأعلى', englishName: 'Al-Ala', englishNameTranslation: 'The Most High', numberOfAyahs: 19, revelationType: 'Meccan'),
      QuranSurah(number: 88, name: 'الغاشية', englishName: 'Al-Ghashiyah', englishNameTranslation: 'The Overwhelming', numberOfAyahs: 26, revelationType: 'Meccan'),
      QuranSurah(number: 89, name: 'الفجر', englishName: 'Al-Fajr', englishNameTranslation: 'The Dawn', numberOfAyahs: 30, revelationType: 'Meccan'),
      QuranSurah(number: 90, name: 'البلد', englishName: 'Al-Balad', englishNameTranslation: 'The City', numberOfAyahs: 20, revelationType: 'Meccan'),
      QuranSurah(number: 91, name: 'الشمس', englishName: 'Ash-Shams', englishNameTranslation: 'The Sun', numberOfAyahs: 15, revelationType: 'Meccan'),
      QuranSurah(number: 92, name: 'الليل', englishName: 'Al-Layl', englishNameTranslation: 'The Night', numberOfAyahs: 21, revelationType: 'Meccan'),
      QuranSurah(number: 93, name: 'الضحى', englishName: 'Ad-Duhaa', englishNameTranslation: 'The Morning Hours', numberOfAyahs: 11, revelationType: 'Meccan'),
      QuranSurah(number: 94, name: 'الشرح', englishName: 'Ash-Sharh', englishNameTranslation: 'The Relief', numberOfAyahs: 8, revelationType: 'Meccan'),
      QuranSurah(number: 95, name: 'التين', englishName: 'At-Tin', englishNameTranslation: 'The Fig', numberOfAyahs: 8, revelationType: 'Meccan'),
      QuranSurah(number: 96, name: 'العلق', englishName: 'Al-Alaq', englishNameTranslation: 'The Clot', numberOfAyahs: 19, revelationType: 'Meccan'),
      QuranSurah(number: 97, name: 'القدر', englishName: 'Al-Qadr', englishNameTranslation: 'The Power', numberOfAyahs: 5, revelationType: 'Meccan'),
      QuranSurah(number: 98, name: 'البينة', englishName: 'Al-Bayyinah', englishNameTranslation: 'The Evidence', numberOfAyahs: 8, revelationType: 'Medinan'),
      QuranSurah(number: 99, name: 'الزلزلة', englishName: 'Az-Zalzalah', englishNameTranslation: 'The Earthquake', numberOfAyahs: 8, revelationType: 'Medinan'),
      QuranSurah(number: 100, name: 'العاديات', englishName: 'Al-Adiyat', englishNameTranslation: 'The Courser', numberOfAyahs: 11, revelationType: 'Meccan'),
      QuranSurah(number: 101, name: 'القارعة', englishName: 'Al-Qariah', englishNameTranslation: 'The Calamity', numberOfAyahs: 11, revelationType: 'Meccan'),
      QuranSurah(number: 102, name: 'التكاثر', englishName: 'At-Takathur', englishNameTranslation: 'The Rivalry In World Increase', numberOfAyahs: 8, revelationType: 'Meccan'),
      QuranSurah(number: 103, name: 'العصر', englishName: 'Al-Asr', englishNameTranslation: 'The Declining Day', numberOfAyahs: 3, revelationType: 'Meccan'),
      QuranSurah(number: 104, name: 'الهمزة', englishName: 'Al-Humazah', englishNameTranslation: 'The Traducer', numberOfAyahs: 9, revelationType: 'Meccan'),
      QuranSurah(number: 105, name: 'الفيل', englishName: 'Al-Fil', englishNameTranslation: 'The Elephant', numberOfAyahs: 5, revelationType: 'Meccan'),
      QuranSurah(number: 106, name: 'قريش', englishName: 'Quraysh', englishNameTranslation: 'Quraysh', numberOfAyahs: 4, revelationType: 'Meccan'),
      QuranSurah(number: 107, name: 'الماعون', englishName: 'Al-Maun', englishNameTranslation: 'The Small Kindnesses', numberOfAyahs: 7, revelationType: 'Meccan'),
      QuranSurah(number: 108, name: 'الكوثر', englishName: 'Al-Kawthar', englishNameTranslation: 'The Abundance', numberOfAyahs: 3, revelationType: 'Meccan'),
      QuranSurah(number: 109, name: 'الكافرون', englishName: 'Al-Kafirun', englishNameTranslation: 'The Disbelievers', numberOfAyahs: 6, revelationType: 'Meccan'),
      QuranSurah(number: 110, name: 'النصر', englishName: 'An-Nasr', englishNameTranslation: 'The Divine Support', numberOfAyahs: 3, revelationType: 'Medinan'),
      QuranSurah(number: 111, name: 'المسد', englishName: 'Al-Masad', englishNameTranslation: 'The Palm Fibre', numberOfAyahs: 5, revelationType: 'Meccan'),
      QuranSurah(number: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', englishNameTranslation: 'The Sincerity', numberOfAyahs: 4, revelationType: 'Meccan'),
      QuranSurah(number: 113, name: 'الفلق', englishName: 'Al-Falaq', englishNameTranslation: 'The Dawn', numberOfAyahs: 5, revelationType: 'Meccan'),
      QuranSurah(number: 114, name: 'الناس', englishName: 'An-Nas', englishNameTranslation: 'Mankind', numberOfAyahs: 6, revelationType: 'Meccan'),
    ];
  }

  /// Get audio URL for specific surah and reciter
  Future<String?> getSurahAudioUrl(int surahNumber, String reciterId) async {
    try {
      // For web platform, return pre-constructed URL
      if (kIsWeb) {
        print('🌐 Web platform - constructing direct audio URL');
        return _constructDirectAudioUrl(surahNumber, reciterId);
      }

      final response = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$reciterId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ Request timeout - using direct URL construction');
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          final ayahs = data['data']['ayahs'] as List;
          if (ayahs.isNotEmpty) {
            return ayahs.first['audio'] as String?;
          }
        }
      }
      
      // Fallback to direct URL construction
      return _constructDirectAudioUrl(surahNumber, reciterId);
      
    } catch (e) {
      print('❌ Error getting surah audio URL: $e - using fallback URL');
      return _constructDirectAudioUrl(surahNumber, reciterId);
    }
  }

  /// Construct direct audio URL when API is not accessible
  String _constructDirectAudioUrl(int surahNumber, String reciterId) {
    // For web platform, use alternative audio sources that work better
    // These are known working URLs for complete surah recitations
    
    final paddedSurahNumber = surahNumber.toString().padLeft(3, '0');
    
    // Use alternative CDN sources for web platform
    if (reciterId == 'ar.alafasy') {
      // Try different formats for Alafasy
      return 'https://server8.mp3quran.net/afs/$paddedSurahNumber.mp3';
    } else if (reciterId == 'ar.abdurrahmaansudais') {
      return 'https://server7.mp3quran.net/sds/$paddedSurahNumber.mp3';
    } else if (reciterId == 'ar.saoodshuraym') {
      return 'https://server7.mp3quran.net/shur/$paddedSurahNumber.mp3';
    } else if (reciterId == 'ar.mahermuaiqly') {
      return 'https://server12.mp3quran.net/maher/$paddedSurahNumber.mp3';
    } else if (reciterId == 'ar.hudhaify') {
      return 'https://server6.mp3quran.net/hudhaify/$paddedSurahNumber.mp3';
    } else if (reciterId == 'ar.ahmedajamy') {
      return 'https://server10.mp3quran.net/ajm/$paddedSurahNumber.mp3';
    }
    
    // Default fallback to Alafasy
    return 'https://server8.mp3quran.net/afs/$paddedSurahNumber.mp3';
  }

  /// Get complete surah with verses and audio
  Future<QuranSurahDetail?> getSurahDetail(int surahNumber, String reciterId) async {
    try {
      // For web platform, handle CORS limitation
      if (kIsWeb) {
        print('🌐 Web platform - using fallback surah detail');
        return _getFallbackSurahDetail(surahNumber, reciterId);
      }

      final response = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$reciterId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ Request timeout - using fallback detail');
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] != null) {
          return QuranSurahDetail.fromJson(data['data']);
        }
      }
      
      return _getFallbackSurahDetail(surahNumber, reciterId);
      
    } catch (e) {
      print('❌ Error getting surah detail: $e - using fallback');
      return _getFallbackSurahDetail(surahNumber, reciterId);
    }
  }

  /// Fallback surah detail when API is not accessible
  QuranSurahDetail? _getFallbackSurahDetail(int surahNumber, String reciterId) {
    final surahData = _getFallbackSurahData().where((s) => s.number == surahNumber).firstOrNull;
    if (surahData == null) return null;

    final audioUrl = _constructDirectAudioUrl(surahNumber, reciterId);
    
    return QuranSurahDetail(
      number: surahData.number,
      name: surahData.name,
      englishName: surahData.englishName,
      englishNameTranslation: surahData.englishNameTranslation,
      numberOfAyahs: surahData.numberOfAyahs,
      revelationType: surahData.revelationType,
      ayahs: [
        QuranAyah(
          number: 1,
          text: 'Audio only mode - verses not available offline',
          audio: audioUrl,
          numberInSurah: 1,
        ),
      ],
    );
  }

  /// Get list of available reciters
  static List<QuranReciter> getReciters() {
    return availableReciters;
  }
}

// Extension for List<QuranSurah>
extension QuranSurahListExtension on List<QuranSurah> {
  QuranSurah? firstOrNull(bool Function(QuranSurah) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Data models
class QuranSurah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  QuranSurah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? '',
    );
  }

  String get formattedName => '$number. $name';
  String get fullName => '$name ($englishName)';
  String get ayahCount => '$numberOfAyahs ayat';
}

class QuranReciter {
  final String id;
  final String name;
  final String language;

  QuranReciter({
    required this.id,
    required this.name,
    required this.language,
  });
}

class QuranAyah {
  final int number;
  final String text;
  final String audio;
  final int numberInSurah;

  QuranAyah({
    required this.number,
    required this.text,
    required this.audio,
    required this.numberInSurah,
  });

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      audio: json['audio'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
    );
  }
}

class QuranSurahDetail {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final List<QuranAyah> ayahs;

  QuranSurahDetail({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.ayahs,
  });

  factory QuranSurahDetail.fromJson(Map<String, dynamic> json) {
    final ayahsData = json['ayahs'] as List? ?? [];
    return QuranSurahDetail(
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      englishName: json['englishName'] ?? '',
      englishNameTranslation: json['englishNameTranslation'] ?? '',
      numberOfAyahs: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? '',
      ayahs: ayahsData.map((ayah) => QuranAyah.fromJson(ayah)).toList(),
    );
  }

  String get fullAudioUrl {
    // Return the first ayah's audio URL (which contains the full surah)
    return ayahs.isNotEmpty ? ayahs.first.audio : '';
  }
}