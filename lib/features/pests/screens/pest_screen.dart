import 'package:flutter/material.dart';
import 'package:petani_maju/data/datasources/pest_services.dart';
import 'package:petani_maju/features/pests/screens/pest_detail_screen.dart';

class PestScreen extends StatefulWidget {
  const PestScreen({super.key});

  @override
  State<PestScreen> createState() => _PestScreenState();
}

class _PestScreenState extends State<PestScreen> {
  final PestService _pestService = PestService();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  // State untuk data
  List<Map<String, dynamic>> _pests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pests = await _pestService.fetchPests(query: _searchQuery);
      setState(() {
        _pests = pests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredPests {
    if (_selectedCategory == 'Semua') return _pests;
    return _pests
        .where((pest) => pest['kategori'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Hama & Penyakit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    // Debounce search
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchQuery == value) {
                        _loadPests();
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari hama atau penyakit...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip('Semua'),
                      _buildChip('Hama Padi'),
                      _buildChip('Hama Jagung'),
                      _buildChip('Hama Umum'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_pests.isEmpty) {
      return const Center(child: Text('Data tidak ditemukan'));
    }

    final filteredPests = _filteredPests;

    if (filteredPests.isEmpty) {
      return const Center(child: Text('Tidak ada hama di kategori ini'));
    }

    return RefreshIndicator(
      onRefresh: _loadPests,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredPests.length,
        itemBuilder: (context, index) {
          final pest = filteredPests[index];
          return _buildPestCard(
            context,
            pest['nama'] ?? 'Tanpa Nama',
            pest['kategori'] ?? 'Umum',
            pest['gambar_url'] ?? '',
            pest,
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data hama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pastikan koneksi internet Anda aktif dan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPests,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
        selected: isSelected,
        selectedColor: Colors.green,
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedCategory = label;
            });
          }
        },
      ),
    );
  }

  Widget _buildPestCard(BuildContext context, String title, String subtitle,
      String imageUrl, Map<String, dynamic> pestData) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade300,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl.startsWith('http')
                ? Image.network(imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image))
                : const Icon(Icons.image, color: Colors.grey),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PestDetailScreen(pest: pestData)),
          );
        },
      ),
    );
  }
}
