import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class DzikirDoaManagementScreen extends StatefulWidget {
  const DzikirDoaManagementScreen({super.key});

  @override
  State<DzikirDoaManagementScreen> createState() => _DzikirDoaManagementScreenState();
}

class _DzikirDoaManagementScreenState extends State<DzikirDoaManagementScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _dzikirDoaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDzikirDoaList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDzikirDoaList({String? search}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the new dedicated method from AdminService
      List<Map<String, dynamic>> data = await _adminService.getDzikirDoa();
      
      // Apply search filter if provided
      if (search != null && search.isNotEmpty) {
        data = data.where((item) {
          final title = (item['title'] ?? '').toString().toLowerCase();
          final category = (item['category']?['name'] ?? '').toString().toLowerCase();
          final arabicText = (item['arabic_text'] ?? '').toString().toLowerCase();
          final translation = (item['indonesian_translation'] ?? '').toString().toLowerCase();
          final searchLower = search.toLowerCase();
          
          return title.contains(searchLower) || 
                 category.contains(searchLower) ||
                 arabicText.contains(searchLower) ||
                 translation.contains(searchLower);
        }).toList();
      }

      setState(() {
        _dzikirDoaList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      _loadDzikirDoaList();
    } else {
      _loadDzikirDoaList(search: query);
    }
  }

  Future<void> _showAddEditDialog({Map<String, dynamic>? item}) async {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final arabicController = TextEditingController(text: item?['arabic_text'] ?? '');
    final translationController = TextEditingController(text: item?['indonesian_translation'] ?? '');
    final benefitsController = TextEditingController(text: item?['benefits'] ?? '');
    final categoryController = TextEditingController(text: item?['category']?['name'] ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Tambah Dzikir/Doa' : 'Edit Dzikir/Doa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: arabicController,
                decoration: const InputDecoration(
                  labelText: 'Teks Arab',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: translationController,
                decoration: const InputDecoration(
                  labelText: 'Terjemahan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: benefitsController,
                decoration: const InputDecoration(
                  labelText: 'Manfaat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || arabicController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Judul dan teks Arab harus diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final data = {
                  'title': titleController.text,
                  'arabic_text': arabicController.text,
                  'indonesian_translation': translationController.text,
                  'benefits': benefitsController.text,
                  'category': categoryController.text,
                };

                if (item == null) {
                  await _adminService.createDzikirDoa(data);
                } else {
                  await _adminService.updateDzikirDoa(item['id'], data);
                }

                Navigator.of(context).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8FA68E),
              foregroundColor: Colors.white,
            ),
            child: Text(item == null ? 'Tambah' : 'Update'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadDzikirDoaList(search: _searchController.text);
    }
  }

  Future<void> _deleteItem(int id, String title) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _adminService.deleteDzikirDoa(id);
        _loadDzikirDoaList(search: _searchController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF8FA68E),
        foregroundColor: Colors.white,
        title: const Text('Manajemen Dzikir & Doa'),
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Cari dzikir/doa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dzikirDoaList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data dzikir/doa',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadDzikirDoaList(search: _searchController.text),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _dzikirDoaList.length,
                    itemBuilder: (context, index) {
                      final item = _dzikirDoaList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8FA68E),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showAddEditDialog(item: item);
                                      } else if (value == 'delete') {
                                        _deleteItem(item['id'], item['title']);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Color(0xFF8FA68E)),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Hapus'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (item['category'] != null && item['category']['name'] != null && item['category']['name'].isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8FA68E).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item['category']['name'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8FA68E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Text(
                                  item['arabic_text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    height: 1.8,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              if (item['indonesian_translation'] != null && item['indonesian_translation'].isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  item['indonesian_translation'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              if (item['benefits'] != null && item['benefits'].isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Color(0xFF8FA68E),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        item['benefits'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFF8FA68E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}