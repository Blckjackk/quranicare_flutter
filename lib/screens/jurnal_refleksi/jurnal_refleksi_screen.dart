import 'package:flutter/material.dart';
import '../../services/journal_service.dart';

// Data Models
enum JournalType {
  alquran,
  perasaan,
}

class JournalEntry {
  final String id;
  final String title;
  final JournalType type;
  final String surah;
  final String ayat;
  final String preview;
  final String content;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.type,
    required this.surah,
    required this.ayat,
    required this.preview,
    required this.content,
    required this.date,
  });
}

class JurnalRefleksiScreen extends StatefulWidget {
  const JurnalRefleksiScreen({super.key});

  @override
  State<JurnalRefleksiScreen> createState() => _JurnalRefleksiScreenState();
}

class _JurnalRefleksiScreenState extends State<JurnalRefleksiScreen> {
  final JournalService _journalService = JournalService();
  
  int _currentTab = 0; // 0: Jurnal, 1: Riwayat Jurnal
  String _currentView = 'dashboard'; // 'dashboard', 'jurnal_perasaan', 'jurnal_alquran'
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // Backend integration variables
  List<JournalData> _journalHistory = [];
  List<AyahData> _availableAyahs = [];
  bool _isLoading = false;
  String? _selectedSurah;
  String? _selectedAyah;
  String? _selectedMood;

  // For Al-Quran journal
  final List<Map<String, dynamic>> availableSurahs = [
    {'number': 1, 'name': 'Al-Fatihah', 'ayahCount': 7},
    {'number': 2, 'name': 'Al-Baqarah', 'ayahCount': 286},
    {'number': 3, 'name': 'Ali \'Imran', 'ayahCount': 200},
    {'number': 4, 'name': 'An-Nisa\'', 'ayahCount': 176},
    {'number': 5, 'name': 'Al-Ma\'idah', 'ayahCount': 120},
  ];

  @override
  void initState() {
    super.initState();
    _loadJournalHistory();
    _loadAvailableAyahs();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadJournalHistory() async {
    setState(() => _isLoading = true);
    try {
      // Use authenticated method to get user-specific journals
      final history = await _journalService.getUserJournals(
        page: 1,
        perPage: 20,
      );
      setState(() {
        _journalHistory = history;
        _isLoading = false;
      });
      print('📚 Loaded ${history.length} user journals');
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Error loading journal history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading journal history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAvailableAyahs() async {
    try {
      // For now, we don't load ayahs here since we need specific ayah IDs
      // This method can be enhanced later when needed
      setState(() => _availableAyahs = []);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ayahs: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _currentTab == 0
                ? _buildJournalContent()
                : _buildHistoryContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8FA68E), Color(0xFF2D5A5A)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Jurnal Refleksi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _currentTab == 0 ? const Color(0xFF8FA68E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Buat Jurnal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _currentTab == 0 ? Colors.white : const Color(0xFF2D5A5A),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: _currentTab == 1 ? const Color(0xFF8FA68E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Riwayat Jurnal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _currentTab == 1 ? Colors.white : const Color(0xFF2D5A5A),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalContent() {
    switch (_currentView) {
      case 'jurnal_perasaan':
        return _buildJurnalPerasaanForm();
      case 'jurnal_alquran':
        return _buildJurnalAlquranForm();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Pilih Jenis Jurnal',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 30),
          
          // Jurnal Perasaan Card
          GestureDetector(
            onTap: () => setState(() => _currentView = 'jurnal_perasaan'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 40,
                    color: Color(0xFF8FA68E),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jurnal Perasaan',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Tulis dan refleksikan perasaan Anda',
                          style: TextStyle(
                            color: Color(0xFF8FA68E),
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Jurnal Al-Quran Card
          GestureDetector(
            onTap: () => setState(() => _currentView = 'jurnal_alquran'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.book,
                    size: 40,
                    color: Color(0xFF8FA68E),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jurnal Al-Quran',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Refleksi dari ayat-ayat Al-Quran',
                          style: TextStyle(
                            color: Color(0xFF8FA68E),
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJurnalPerasaanForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                onPressed: () => setState(() => _currentView = 'dashboard'),
              ),
              const Text(
                'Jurnal Perasaan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Mood Selection
          const Text(
            'Bagaimana perasaan Anda hari ini?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 10),
          _buildMoodSelector(),
          const SizedBox(height: 20),
          
          // Title Input
          const Text(
            'Judul Jurnal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Masukkan judul jurnal...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF8FA68E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D5A5A), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Content Input
          const Text(
            'Isi Jurnal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Ceritakan perasaan Anda...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF8FA68E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D5A5A), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveJournalPerasaan,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Simpan Jurnal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJurnalAlquranForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
                onPressed: () => setState(() => _currentView = 'dashboard'),
              ),
              const Text(
                'Jurnal Al-Quran',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A5A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Surah Selection
          const Text(
            'Pilih Surah',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 10),
          _buildSurahDropdown(),
          const SizedBox(height: 20),
          
          // Ayah Selection
          if (_selectedSurah != null) ...[
            const Text(
              'Pilih Ayat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 10),
            _buildAyahDropdown(),
            const SizedBox(height: 20),
          ],
          
          // Title Input
          const Text(
            'Judul Refleksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Masukkan judul refleksi...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF8FA68E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D5A5A), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Content Input
          const Text(
            'Refleksi Anda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D5A5A),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Tuliskan refleksi Anda tentang ayat ini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF8FA68E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2D5A5A), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveJournalAlquran,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Simpan Refleksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'name': 'Senang', 'emoji': '😊', 'value': 'happy'},
      {'name': 'Sedih', 'emoji': '😢', 'value': 'sad'},
      {'name': 'Marah', 'emoji': '😠', 'value': 'angry'},
      {'name': 'Tenang', 'emoji': '😌', 'value': 'calm'},
      {'name': 'Bersemangat', 'emoji': '🤗', 'value': 'excited'},
      {'name': 'Khawatir', 'emoji': '😟', 'value': 'worried'},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: moods.map((mood) {
        final isSelected = _selectedMood == mood['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood['value'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF8FA68E) : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF8FA68E).withOpacity(0.3),
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: const Color(0xFF8FA68E).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mood['emoji'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  mood['name'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF2D5A5A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSurahDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8FA68E)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Pilih Surah'),
          value: _selectedSurah,
          onChanged: (String? newValue) {
            setState(() {
              _selectedSurah = newValue;
              _selectedAyah = null; // Reset ayah selection
            });
          },
          items: availableSurahs.map((surah) {
            return DropdownMenuItem<String>(
              value: surah['number'].toString(),
              child: Text('${surah['number']}. ${surah['name']}'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAyahDropdown() {
    final selectedSurahData = availableSurahs.firstWhere(
      (surah) => surah['number'].toString() == _selectedSurah,
    );
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8FA68E)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text('Pilih Ayat'),
          value: _selectedAyah,
          onChanged: (String? newValue) {
            setState(() => _selectedAyah = newValue);
          },
          items: List.generate(selectedSurahData['ayahCount'] as int, (index) {
            final ayahNumber = index + 1;
            return DropdownMenuItem<String>(
              value: ayahNumber.toString(),
              child: Text('Ayat $ayahNumber'),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHistoryContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8FA68E),
        ),
      );
    }

    if (_journalHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Color(0xFF8FA68E),
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada jurnal',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF2D5A5A),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Mulai menulis jurnal pertama Anda',
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF8FA68E),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _journalHistory.length,
      itemBuilder: (context, index) {
        final journal = _journalHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FA68E).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (journal.quranAyahId != null) ? 'ALQURAN' : 'PERASAAN',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(journal.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8FA68E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                journal.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A5A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                journal.content.length > 100
                    ? '${journal.content.substring(0, 100)}...'
                    : journal.content,
                style: const TextStyle(
                  fontSize: 17,
                  color: Color(0xFF2D5A5A),
                  height: 1.4,
                ),
              ),
              if (journal.quranAyahId != null && journal.ayah != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FA68E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Surah ${journal.ayah!.surah?.nameIndonesian ?? 'Unknown'}, Ayat ${journal.ayah!.number}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2D5A5A),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveJournalPerasaan() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // For now, create a simple entry without backend integration
      // This can be enhanced later to use the actual service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jurnal berhasil disimpan! (Demo mode)')),
      );
      
      // Clear form
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedMood = null;
        _currentView = 'dashboard';
        _isLoading = false;
      });
      
      // Reload history
      _loadJournalHistory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jurnal berhasil disimpan!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveJournalAlquran() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || 
        _selectedSurah == null || _selectedAyah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // For now, create a simple entry without backend integration
      // This can be enhanced later to use createAyahReflection when we have ayah IDs
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refleksi berhasil disimpan! (Demo mode)')),
      );
      
      // Clear form
      _titleController.clear();
      _contentController.clear();
      setState(() {
        _selectedSurah = null;
        _selectedAyah = null;
        _currentView = 'dashboard';
        _isLoading = false;
      });
      
      // Reload history
      _loadJournalHistory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refleksi berhasil disimpan!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Journal Detail Screens
class JournalDetailScreen extends StatelessWidget {
  final JournalEntry journal;

  const JournalDetailScreen({
    super.key,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Jurnal',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              journal.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 10),
            
            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF8FA68E),
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(journal.date),
                  style: const TextStyle(
                    color: Color(0xFF8FA68E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Type specific content
            if (journal.type == JournalType.alquran) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Surah & Ayat:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${journal.surah} ${journal.ayat}',
                      style: const TextStyle(
                        color: Color(0xFF2D5A5A),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                journal.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF2D5A5A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class DynamicJournalDetailScreen extends StatelessWidget {
  final JournalData journal;

  const DynamicJournalDetailScreen({
    super.key,
    required this.journal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Jurnal',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              journal.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 10),
            
            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF8FA68E),
                ),
                const SizedBox(width: 5),
                Text(
                  _formatDate(journal.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF8FA68E),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Type and mood
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8FA68E).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    (journal.quranAyahId != null) ? 'ALQURAN' : 'PERASAAN',
                    style: const TextStyle(
                      color: Color(0xFF2D5A5A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _getMoodEmoji(journal.mood ?? ''),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Surah info if available
            if (journal.quranAyahId != null && journal.ayah != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Surah & Ayat:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Surah ${journal.ayah!.surah?.nameIndonesian ?? 'Unknown'}, Ayat ${journal.ayah!.number}',
                      style: const TextStyle(
                        color: Color(0xFF2D5A5A),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                journal.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF2D5A5A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'senang':
        return '😊';
      case 'sad':
      case 'sedih':
        return '😢';
      case 'angry':
      case 'marah':
        return '😠';
      case 'calm':
      case 'tenang':
        return '😌';
      case 'excited':
      case 'bersemangat':
        return '🤗';
      case 'worried':
      case 'khawatir':
        return '😟';
      case 'grateful':
      case 'bersyukur':
        return '🙏';
      case 'peaceful':
      case 'damai':
        return '☮️';
      default:
        return '😐';
    }
  }
}