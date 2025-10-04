import 'package:flutter/material.dart';
import '../models/doa_dzikir.dart';
import '../services/doa_dzikir_service.dart';
import '../widgets/doa_dzikir_session_dialog.dart';
import '../utils/font_styles.dart';

class DoaDzikirScreen extends StatefulWidget {
  const DoaDzikirScreen({super.key});

  @override
  State<DoaDzikirScreen> createState() => _DoaDzikirScreenState();
}

class _DoaDzikirScreenState extends State<DoaDzikirScreen> {
  final DoaDzikirService _doaDzikirService = DoaDzikirService();
  List<DoaDzikir> _doaDzikirList = [];
  List<String> _groups = [];
  List<String> _tags = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  String? _selectedGroup;
  String? _selectedTag;
  String _searchQuery = '';
  bool _showFeaturedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      print('🟡 Starting to load initial data...');
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Load doa dzikir first
      print('🟡 Loading doa dzikir...');
      await _loadDoaDzikir();
      print('🟡 Doa dzikir loaded successfully: ${_doaDzikirList.length} items');
      
      // Load groups and tags separately to avoid blocking the main content
      try {
        print('🟡 Loading groups...');
        final groups = await _doaDzikirService.getGroups();
        setState(() {
          _groups = groups;
        });
        print('🟡 Groups loaded: ${groups.length}');
      } catch (e) {
        print('❌ Error loading groups: $e');
        // Continue without groups
      }
      
      try {
        print('🟡 Loading tags...');
        final tags = await _doaDzikirService.getTags();
        setState(() {
          _tags = tags;
        });
        print('🟡 Tags loaded: ${tags.length}');
      } catch (e) {
        print('❌ Error loading tags: $e');
        // Continue without tags
      }
      
      setState(() {
        _isLoading = false;
      });
      print('🟢 Initial data load completed successfully');
    } catch (e) {
      print('❌ Error in _loadInitialData: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDoaDzikir({bool showLoading = false}) async {
    try {
      print('🔵 _loadDoaDzikir called with showLoading: $showLoading');
      if (showLoading) {
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });
      }

      print('🔵 Calling service with params - grup: $_selectedGroup, tag: $_selectedTag, search: ${_searchQuery.isNotEmpty ? _searchQuery : null}, featured: $_showFeaturedOnly');
      final result = await _doaDzikirService.getAllDoaDzikir(
        grup: _selectedGroup,
        tag: _selectedTag,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        featured: _showFeaturedOnly,
      );
      
      print('🔵 Service returned result with keys: ${result.keys}');
      final doaDzikirData = result['doa_dzikir'];
      print('🔵 DoaDzikir data type: ${doaDzikirData.runtimeType}, length: ${doaDzikirData is List ? doaDzikirData.length : 'not list'}');
      
      setState(() {
        _doaDzikirList = result['doa_dzikir'] as List<DoaDzikir>;
        if (showLoading) _isLoading = false;
      });
      
      print('🔵 State updated - list length: ${_doaDzikirList.length}');
    } catch (e) {
      print('❌ Error in _loadDoaDzikir: $e');
      setState(() {
        _errorMessage = e.toString();
        if (showLoading) _isLoading = false;
      });
    }
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B7D6A).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _loadDoaDzikir();
            },
            decoration: InputDecoration(
              hintText: 'Cari doa atau dzikir...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF8FA68E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF8FA68E).withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF8FA68E)),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Featured filter
                FilterChip(
                  label: const Text('Unggulan'),
                  selected: _showFeaturedOnly,
                  onSelected: (bool selected) {
                    setState(() {
                      _showFeaturedOnly = selected;
                    });
                    _loadDoaDzikir(showLoading: true);
                  },
                  selectedColor: const Color(0xFF8FA68E).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF6B7D6A),
                ),
                
                const SizedBox(width: 8),
                
                // Group filter
                DropdownButton<String>(
                  hint: const Text('Grup'),
                  value: _selectedGroup,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGroup = newValue;
                    });
                    _loadDoaDzikir(showLoading: true);
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Grup'),
                    ),
                    ..._groups.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ],
                ),
                
                const SizedBox(width: 8),
                
                // Tag filter
                DropdownButton<String>(
                  hint: const Text('Tag'),
                  value: _selectedTag,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTag = newValue;
                    });
                    _loadDoaDzikir(showLoading: true);
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Tag'),
                    ),
                    ..._tags.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoaDzikirCard(DoaDzikir doaDzikir) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoaDzikirDetailScreen(doaDzikir: doaDzikir),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and group
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        doaDzikir.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D4538),
                        ),
                      ),
                    ),
                    if (doaDzikir.grup.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8FA68E).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doaDzikir.grup,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7D6A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Arabic text (preview) - UPDATED FONT SIZE
                if (doaDzikir.ar.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Arabic text with updated Amiri font
                        ArabicText(
                          doaDzikir.ar.length > 100 
                              ? '${doaDzikir.ar.substring(0, 100)}...'
                              : doaDzikir.ar,
                          style: FontStyles.doaText.copyWith(
                            color: const Color(0xFF6B7D6A),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Indonesian translation (preview)
                if (doaDzikir.idn.isNotEmpty)
                  Text(
                    doaDzikir.idn.length > 150 
                        ? '${doaDzikir.idn.substring(0, 150)}...'
                        : doaDzikir.idn,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8FA68E),
                      height: 1.4,
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Tags
                if (doaDzikir.tag.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: doaDzikir.tag.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF8FA68E).withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag.trim(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8FA68E),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FA68E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Doa & Dzikir Ketenangan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8FA68E),
                Color(0xFF6B7D6A),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8FA68E)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat doa dan dzikir...',
                          style: TextStyle(
                            color: const Color(0xFF8FA68E).withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.all(32),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B7D6A).withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Gagal Memuat Data',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7D6A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage.contains('Failed to load')
                                    ? 'Terjadi kesalahan saat menghubungi server. Periksa koneksi internet Anda.'
                                    : _errorMessage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadInitialData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8FA68E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Coba Lagi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _doaDzikirList.isEmpty
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(32),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.menu_book_outlined,
                                    size: 64,
                                    color: const Color(0xFF8FA68E).withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tidak Ada Data',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6B7D6A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada doa atau dzikir yang sesuai dengan filter Anda.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF8FA68E).withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDoaDzikir,
                            child: ListView.builder(
                              itemCount: _doaDzikirList.length,
                              itemBuilder: (context, index) {
                                final doaDzikir = _doaDzikirList[index];
                                return _buildDoaDzikirCard(doaDzikir);
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B7D6A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home, 'Home', false),
                _buildNavItem(1, Icons.book, 'Al Quran', false),
                _buildNavItem(2, Icons.chat_bubble, 'Qalbu Chat', false),
                _buildNavItem(3, Icons.person, 'Profil', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class DoaDzikirDetailScreen extends StatelessWidget {
  final DoaDzikir doaDzikir;

  const DoaDzikirDetailScreen({super.key, required this.doaDzikir});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7D6A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Doa dan Dzikir Ketenangan',
          style: TextStyle(
            color: Color(0xFF6B7D6A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B7D6A).withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  doaDzikir.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7D6A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Arabic text card
              if (doaDzikir.ar.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B7D6A).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ArabicText(
                    doaDzikir.ar,
                    style: FontStyles.ayahText.copyWith(
                      color: const Color(0xFF6B7D6A),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Transliteration and Translation
              if (doaDzikir.tr.isNotEmpty || doaDzikir.idn.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B7D6A).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (doaDzikir.tr.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transliterasi:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B7D6A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doaDzikir.tr,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF6B7D6A),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      if (doaDzikir.tr.isNotEmpty && doaDzikir.idn.isNotEmpty)
                        const SizedBox(height: 16),
                      if (doaDzikir.idn.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Artinya:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B7D6A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doaDzikir.idn,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8FA68E),
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // About/Description section
              if (doaDzikir.tentang.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B7D6A).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Penjelasan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7D6A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doaDzikir.tentang,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7D6A),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),

              // Tags section
              if (doaDzikir.tag.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B7D6A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: doaDzikir.tag.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8FA68E).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7D6A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              // Session tracking section
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF8FA68E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8FA68E).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Mulai Sesi Dzikir',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7D6A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        _showSessionDialog(context, doaDzikir);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8FA68E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Mulai Dzikir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B7D6A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home, 'Home', false),
                _buildNavItem(1, Icons.book, 'Al Quran', false),
                _buildNavItem(2, Icons.chat_bubble, 'Qalbu Chat', false),
                _buildNavItem(3, Icons.person, 'Profil', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
  void _showSessionDialog(BuildContext context, DoaDzikir doaDzikir) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DoaDzikirSessionDialog(doaDzikir: doaDzikir);
      },
    );
  }
}

