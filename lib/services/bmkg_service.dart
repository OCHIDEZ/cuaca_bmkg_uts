import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/earthquake_model.dart';

class RegionItem {
  final String id;
  final String name;

  RegionItem({required this.id, required this.name});
}

class BmkgService {
  static const String _weatherUrl =
      'https://api.bmkg.go.id/publik/prakiraan-cuaca';
  static const String _autoGempaUrl =
      'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json';
  static const String _gempaTerkiniUrl =
      'https://data.bmkg.go.id/DataMKG/TEWS/gempaterkini.json';

  static const String _kepmendagriBaseUrl =
      'https://raw.githubusercontent.com/Wiilly04/Wilayah-Administrasi-Indonesia/master/api';

  static final Map<String, BmkgWeatherResponse> _weatherCache = {};

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent': 'Flutter-BMKG-Info-UTS/1.0',
  };

  Future<BmkgWeatherResponse> fetchWeather(String adm4Code,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _weatherCache.containsKey(adm4Code)) {
      return _weatherCache[adm4Code]!;
    }

    final Uri url = Uri.parse('$_weatherUrl?adm4=$adm4Code');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['data'] == null || (jsonData['data'] as List).isEmpty) {
        throw Exception('Data kode $adm4Code kosong');
      }
      final result = BmkgWeatherResponse.fromJson(jsonData);
      _weatherCache[adm4Code] = result;
      return result;
    } else if (response.statusCode == 429) {
      await Future.delayed(const Duration(seconds: 2));
      final retryRes = await http.get(url, headers: _headers);
      if (retryRes.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(retryRes.body);
        final result = BmkgWeatherResponse.fromJson(jsonData);
        _weatherCache[adm4Code] = result;
        return result;
      }
      throw Exception(
          'Server BMKG sedang membatasi akses cepat (Status 429). Tunggu 5 detik lalu tekan Coba Lagi.');
    } else {
      throw Exception('Status: ${response.statusCode}');
    }
  }

  Future<BmkgEarthquakeBundle> fetchEarthquakeData() async {
    final results = await Future.wait([
      http.get(Uri.parse(_autoGempaUrl), headers: _headers),
      http.get(Uri.parse(_gempaTerkiniUrl), headers: _headers),
    ]);

    final autoRes = results[0];
    final listRes = results[1];

    if (autoRes.statusCode == 200 && listRes.statusCode == 200) {
      final autoJson = json.decode(autoRes.body);
      final listJson = json.decode(listRes.body);

      final autoGempa =
      EarthquakeItem.fromJson(autoJson['Infogempa']['gempa']);

      final List<dynamic> rawList = listJson['Infogempa']['gempa'] ?? [];
      final listGempa = rawList
          .map((item) => EarthquakeItem.fromJson(item as Map<String, dynamic>))
          .toList();

      return BmkgEarthquakeBundle(
        autoGempa: autoGempa,
        listGempaTerkini: listGempa,
      );
    } else {
      throw Exception('Gagal memuat data gempa bumi BMKG');
    }
  }

  static const String _wilayahUrl =
      'https://ibnux.github.io/data-indonesia';

  Future<List<RegionItem>> fetchProvinces() async {
    final res = await http.get(Uri.parse('$_wilayahUrl/propinsi.json'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data
          .map((e) => RegionItem(
        id: e['id'].toString(),
        name: e['nama'].toString(),
      ))
          .toList();
    }
    throw Exception('Gagal memuat daftar provinsi');
  }

  Future<List<RegionItem>> fetchRegencies(String provinceId) async {
    final res =
    await http.get(Uri.parse('$_wilayahUrl/kabupaten/$provinceId.json'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data
          .map((e) => RegionItem(
        id: e['id'].toString(),
        name: e['nama'].toString(),
      ))
          .toList();
    }
    throw Exception('Gagal memuat daftar kabupaten/kota');
  }

  Future<List<RegionItem>> fetchDistricts(String regencyId) async {
    final res =
    await http.get(Uri.parse('$_wilayahUrl/kecamatan/$regencyId.json'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data
          .map((e) => RegionItem(
        id: e['id'].toString(),
        name: e['nama'].toString(),
      ))
          .toList();
    }
    throw Exception('Gagal memuat daftar kecamatan');
  }

  Future<List<RegionItem>> fetchVillages(String districtId) async {
    final res =
    await http.get(Uri.parse('$_wilayahUrl/kelurahan/$districtId.json'));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) {
        final rawId = e['id'].toString();
        final formattedAdm4 = rawId.length == 10
            ? '${rawId.substring(0, 2)}.${rawId.substring(2, 4)}.${rawId.substring(4, 6)}.${rawId.substring(6, 10)}'
            : rawId;
        return RegionItem(
          id: formattedAdm4,
          name: e['nama'].toString(),
        );
      }).toList();
    }
    throw Exception('Gagal memuat daftar kelurahan/desa');
  }
}