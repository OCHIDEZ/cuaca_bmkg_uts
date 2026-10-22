import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../models/earthquake_model.dart';
import '../services/bmkg_service.dart';

class EarthquakeScreen extends StatefulWidget {
  const EarthquakeScreen({super.key});

  @override
  State<EarthquakeScreen> createState() => _EarthquakeScreenState();
}

class _EarthquakeScreenState extends State<EarthquakeScreen> {
  final BmkgService _bmkgService = BmkgService();
  final MapController _mapController = MapController();

  late Future<BmkgEarthquakeBundle> _earthquakeFuture;
  EarthquakeItem? _selectedQuakeOnMap;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _selectedQuakeOnMap = null;
      _earthquakeFuture = _bmkgService.fetchEarthquakeData();
    });
  }

  void _focusQuakeOnMap(EarthquakeItem quake) {
    setState(() {
      _selectedQuakeOnMap = quake;
    });
    _mapController.move(quake.latLng, 7.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Peta & Info Gempa BMKG',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<BmkgEarthquakeBundle>(
        future: _earthquakeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Terjadi Kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Data gempa tidak tersedia.'));
          }

          final autoGempa = snapshot.data!.autoGempa;
          final listGempa = snapshot.data!.listGempaTerkini;
          final activeQuake = _selectedQuakeOnMap ?? autoGempa;

          return Column(
            children: [
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: autoGempa.latLng,
                        initialZoom: 5.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.uts.bmkg_info',
                        ),
                        MarkerLayer(
                          markers: [
                            ...listGempa.map(
                                  (q) => Marker(
                                point: q.latLng,
                                width: 40,
                                height: 40,
                                child: GestureDetector(
                                  onTap: () => _focusQuakeOnMap(q),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.withOpacity(0.85),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      q.magnitude,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Marker(
                              point: autoGempa.latLng,
                              width: 52,
                              height: 52,
                              child: GestureDetector(
                                onTap: () => _focusQuakeOnMap(autoGempa),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB71C1C),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.amberAccent, width: 2.5),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    autoGempa.magnitude,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                                radius: 5, backgroundColor: Color(0xFFB71C1C)),
                            SizedBox(width: 4),
                            Text('Gempa Terbaru',
                                style: TextStyle(fontSize: 11)),
                            SizedBox(width: 10),
                            CircleAvatar(
                                radius: 5, backgroundColor: Colors.deepOrange),
                            SizedBox(width: 4),
                            Text('Gempa M ≥ 5.0',
                                style: TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: FloatingActionButton.small(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFB71C1C),
                        tooltip: 'Fokus Gempa Terbaru',
                        onPressed: () => _focusQuakeOnMap(autoGempa),
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedQuakeOnMap == null
                                ? 'Detail Gempa Terbaru (Real-Time)'
                                : 'Detail Titik Gempa Terpilih',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          if (_selectedQuakeOnMap != null)
                            TextButton(
                              onPressed: () => _focusQuakeOnMap(autoGempa),
                              child: const Text('Kembali ke Terbaru',
                                  style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildSelectedQuakeCard(activeQuake),
                      const SizedBox(height: 20),
                      const Text(
                        '15 Gempa Bumi Terkini (M ≥ 5.0) — Ketuk untuk Lihat di Peta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...listGempa.map((q) => _buildQuakeTile(q)),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Sumber Data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedQuakeCard(EarthquakeItem quake) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'MAGNITUDO',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        quake.magnitude,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quake.wilayah,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quake.tanggal} • ${quake.jam}',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(
                Icons.vertical_align_bottom, 'Kedalaman', quake.kedalaman),
            _buildInfoRow(Icons.my_location, 'Koordinat',
                '${quake.lintang}, ${quake.bujur}'),
            _buildInfoRow(
                Icons.warning_amber_rounded, 'Potensi', quake.potensi),
            if (quake.dirasakan != '-')
              _buildInfoRow(Icons.sensors, 'Dirasakan (MMI)', quake.dirasakan),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFB71C1C)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuakeTile(EarthquakeItem item) {
    final isSelected = _selectedQuakeOnMap?.jam == item.jam &&
        _selectedQuakeOnMap?.tanggal == item.tanggal;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? const Color(0xFFFFEBEE) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Color(0xFFB71C1C), width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        onTap: () => _focusQuakeOnMap(item),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFEBEE),
          child: Text(
            item.magnitude,
            style: const TextStyle(
              color: Color(0xFFB71C1C),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          item.wilayah,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          '${item.tanggal} (${item.jam})\nKedalaman: ${item.kedalaman} | ${item.potensi}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.map_outlined, color: Color(0xFFB71C1C)),
        isThreeLine: true,
      ),
    );
  }
}