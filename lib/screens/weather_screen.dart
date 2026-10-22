import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/bmkg_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final BmkgService _bmkgService = BmkgService();

  String _selectedRegencyId = '3573';
  String _selectedRegencyName = 'KOTA MALANG, JAWA TIMUR';

  List<RegionItem> _districts = [];
  RegionItem? _selectedDistrict;
  bool _isLoadingDistricts = false;

  Future<BmkgWeatherResponse>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _loadRegencyDistricts(_selectedRegencyId);
  }

  Future<void> _loadRegencyDistricts(String regencyId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
    });

    try {
      final districtList = await _bmkgService.fetchDistricts(regencyId);
      if (districtList.isNotEmpty) {
        setState(() {
          _districts = districtList;
          _selectedDistrict = districtList.first;
          _isLoadingDistricts = false;
        });
        _loadWeatherForDistrict(districtList.first);
      } else {
        setState(() {
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingDistricts = false;
      });
    }
  }

  void _loadWeatherForDistrict(RegionItem district,
      {bool forceRefresh = false}) {
    setState(() {
      _selectedDistrict = district;
      _weatherFuture =
          _fetchWeatherByDistrictId(district.id, forceRefresh: forceRefresh);
    });
  }

  Future<BmkgWeatherResponse> _fetchWeatherByDistrictId(String districtId,
      {bool forceRefresh = false}) async {
    final villages = await _bmkgService.fetchVillages(districtId);
    if (villages.isEmpty) {
      throw Exception('Data wilayah kecamatan tidak ditemukan.');
    }
    return await _bmkgService.fetchWeather(
      villages.first.id,
      forceRefresh: forceRefresh,
    );
  }

  void _showRegencyPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _RegencySelectorSheet(
          bmkgService: _bmkgService,
          onRegencySelected: (regencyId, regencyLabel) {
            setState(() {
              _selectedRegencyId = regencyId;
              _selectedRegencyName = regencyLabel;
            });
            _loadRegencyDistricts(regencyId);
          },
        );
      },
    );
  }

  IconData _getWeatherIcon(String desc) {
    final lower = desc.toLowerCase();
    if (lower.contains('petir')) return Icons.thunderstorm;
    if (lower.contains('hujan')) return Icons.umbrella;
    if (lower.contains('berawan')) return Icons.cloud;
    if (lower.contains('cerah')) return Icons.wb_sunny;
    return Icons.wb_cloudy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text(
          'Prakiraan Cuaca BMKG',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: () {
              if (_selectedDistrict != null) {
                _loadWeatherForDistrict(_selectedDistrict!,
                    forceRefresh: true);
              } else {
                _loadRegencyDistricts(_selectedRegencyId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            color: const Color(0xFF1565C0),
            child: InkWell(
              onTap: _showRegencyPickerSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_city, color: Color(0xFF1565C0)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kabupaten / Kota Terpilih:',
                            style:
                            TextStyle(fontSize: 11, color: Colors.black54),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedRegencyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.edit_location_alt,
                              size: 16, color: Color(0xFF1565C0)),
                          SizedBox(width: 4),
                          Text(
                            'Ganti Kota/Kab',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _isLoadingDistricts
                ? const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Pilih Kecamatan:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _districts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final kec = _districts[index];
                      final isSelected = _selectedDistrict?.id == kec.id;

                      return ChoiceChip(
                        label: Text('Kec. ${kec.name}'),
                        selected: isSelected,
                        selectedColor: const Color(0xFF1565C0),
                        backgroundColor: const Color(0xFFF1F5F9),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                          isSelected ? Colors.white : Colors.black87,
                        ),
                        onSelected: (_) => _loadWeatherForDistrict(kec),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _weatherFuture == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<BmkgWeatherResponse>(
              future: _weatherFuture,
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
                            'Gagal memuat cuaca kecamatan:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_selectedDistrict != null) {
                                _loadWeatherForDistrict(
                                  _selectedDistrict!,
                                  forceRefresh: true,
                                );
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data!.listCuaca.isEmpty) {
                  return const Center(
                      child:
                      Text('Data prakiraan cuaca tidak tersedia.'));
                }

                final lokasi = snapshot.data!.lokasi;
                final listCuaca = snapshot.data!.listCuaca;
                final current = listCuaca.first;

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_selectedDistrict != null) {
                      _loadWeatherForDistrict(
                        _selectedDistrict!,
                        forceRefresh: true,
                      );
                    }
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHighlightCard(lokasi, current),
                      const SizedBox(height: 20),
                      Text(
                        'Jadwal Prakiraan 3 Hari (Kec. ${lokasi.kecamatan})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...listCuaca.map((item) => _buildForecastTile(item)),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(LocationInfo lokasi, WeatherItem current) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kecamatan ${lokasi.kecamatan}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${lokasi.kotkab} - ${lokasi.provinsi} (Area: ${lokasi.desa})',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperature}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      current.weatherDesc,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Waktu: ${current.localDatetime}',
                      style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                _getWeatherIcon(current.weatherDesc),
                size: 72,
                color: Colors.amberAccent,
              ),
            ],
          ),
          const Divider(color: Colors.white30, height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricInfo(
                  Icons.water_drop, 'Kelembapan', '${current.humidity}%'),
              _buildMetricInfo(Icons.air, 'Angin',
                  '${current.windSpeed} km/j (${current.windDirection})'),
              _buildMetricInfo(
                  Icons.visibility, 'Jarak Pandang', current.visibilityText),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastTile(WeatherItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE3F2FD),
          child: Icon(
            _getWeatherIcon(item.weatherDesc),
            color: const Color(0xFF1565C0),
          ),
        ),
        title: Text(
          '${item.weatherDesc} • ${item.temperature}°C',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'Waktu: ${item.localDatetime}\nKelembapan: ${item.humidity}% | Angin: ${item.windSpeed} km/jam (${item.windDirection})',
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_queue, size: 16, color: Colors.grey),
            Text('${item.cloudCover}%', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _RegencySelectorSheet extends StatefulWidget {
  final BmkgService bmkgService;
  final void Function(String regencyId, String regencyLabel) onRegencySelected;

  const _RegencySelectorSheet({
    required this.bmkgService,
    required this.onRegencySelected,
  });

  @override
  State<_RegencySelectorSheet> createState() => _RegencySelectorSheetState();
}

class _RegencySelectorSheetState extends State<_RegencySelectorSheet> {
  List<RegionItem> _provinces = [];
  List<RegionItem> _regencies = [];

  RegionItem? _selectedProvince;
  RegionItem? _selectedRegency;

  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final list = await widget.bmkgService.fetchProvinces();
      setState(() {
        _provinces = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _onProvinceChanged(RegionItem? prov) async {
    if (prov == null) return;
    setState(() {
      _selectedProvince = prov;
      _selectedRegency = null;
      _regencies = [];
      _isLoading = true;
    });
    try {
      final list = await widget.bmkgService.fetchRegencies(prov.id);
      setState(() {
        _regencies = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Pilih Kabupaten / Kota',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cukup pilih Provinsi dan Kabupaten/Kota, daftar Kecamatan akan muncul otomatis:',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMsg!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          DropdownButtonFormField<RegionItem>(
            value: _selectedProvince,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: '1. Pilih Provinsi',
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _provinces.map((item) {
              return DropdownMenuItem<RegionItem>(
                value: item,
                child: Text(item.name, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: _onProvinceChanged,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<RegionItem>(
            value: _selectedRegency,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: '2. Pilih Kabupaten / Kota',
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: _regencies.map((item) {
              return DropdownMenuItem<RegionItem>(
                value: item,
                child: Text(item.name, style: const TextStyle(fontSize: 13)),
              );
            }).toList(),
            onChanged: _regencies.isEmpty
                ? null
                : (val) {
              setState(() {
                _selectedRegency = val;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _selectedRegency == null
                  ? null
                  : () {
                final label =
                    '${_selectedRegency!.name}, ${_selectedProvince!.name}';
                widget.onRegencySelected(_selectedRegency!.id, label);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Tampilkan Kecamatan & Cuaca',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}