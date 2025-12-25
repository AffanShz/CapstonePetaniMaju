import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:petani_maju/features/pests/bloc/pest_bloc.dart';
import 'package:petani_maju/features/pests/screens/pest_detail_screen.dart';
import 'package:petani_maju/data/repositories/pest_repository.dart';

class PestScreen extends StatefulWidget {
  const PestScreen({super.key});

  @override
  State<PestScreen> createState() => _PestScreenState();
}

class _PestScreenState extends State<PestScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PestBloc(
        pestRepository: context.read<PestRepository>(),
      )..add(LoadPests()),
      child: Scaffold(
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
                  BlocBuilder<PestBloc, PestState>(
                    builder: (context, state) {
                      return TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          // Debounce search
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_searchController.text == value) {
                              context
                                  .read<PestBloc>()
                                  .add(SearchPests(query: value));
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
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips
                  BlocBuilder<PestBloc, PestState>(
                    builder: (context, state) {
                      final selectedCategory = state is PestLoaded
                          ? state.selectedCategory
                          : 'Semua';

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildChip(context, 'Semua', selectedCategory),
                            _buildChip(context, 'Hama Padi', selectedCategory),
                            _buildChip(
                                context, 'Hama Jagung', selectedCategory),
                            _buildChip(context, 'Hama Umum', selectedCategory),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<PestBloc, PestState>(
                builder: (context, state) {
                  if (state is PestLoading || state is PestInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PestError) {
                    return _buildErrorWidget(context, state.message);
                  }

                  if (state is PestLoaded) {
                    return _buildPestList(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPestList(BuildContext context, PestLoaded state) {
    final pests = state.filteredPests;

    if (pests.isEmpty) {
      return Center(
        child: Text(
          state.searchQuery.isNotEmpty || state.selectedCategory != 'Semua'
              ? 'Tidak ada hama ditemukan'
              : 'Data tidak ditemukan',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PestBloc>().add(RefreshPests());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pests.length,
        itemBuilder: (context, index) {
          final pest = pests[index];
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

  Widget _buildErrorWidget(BuildContext context, String message) {
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
              onPressed: () {
                context.read<PestBloc>().add(LoadPests());
              },
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

  Widget _buildChip(
      BuildContext context, String label, String selectedCategory) {
    final isSelected = selectedCategory == label;
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
            context
                .read<PestBloc>()
                .add(FilterPestsByCategory(category: label));
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
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  )
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
