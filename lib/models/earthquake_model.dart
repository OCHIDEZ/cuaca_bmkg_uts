import 'package:latlong2/latlong.dart';

class EarthquakeItem {
  final String tanggal;
  final String jam;
  final String coordinates;
  final String lintang;
  final String bujur;
  final String magnitude;
  final String kedalaman;
  final String wilayah;
  final String potensi;
  final String dirasakan;
  final String? shakemap;

  EarthquakeItem({
    required this.tanggal,
    required this.jam,
    required this.coordinates,
    required this.lintang,
    required this.bujur,
    required this.magnitude,
    required this.kedalaman,
    required this.wilayah,
    required this.potensi,
    required this.dirasakan,
    this.shakemap,
  });

  factory EarthquakeItem.fromJson(Map<String, dynamic> json) {
    return EarthquakeItem(
      tanggal: json['Tanggal'] ?? '-',
      jam: json['Jam'] ?? '-',
      coordinates: json['Coordinates'] ?? '0.0.0.0',
      lintang: json['Lintang'] ?? '-',
      bujur: json['Bujur'] ?? '-',
      magnitude: json['Magnitude']?.toString() ?? '-',
      kedalaman: json['Kedalaman'] ?? '-',
      wilayah: json['Wilayah'] ?? '-',
      potensi: json['Potensi'] ?? '-',
      dirasakan: json['Dirasakan'] ?? '-',
      shakemap: json['Shakemap'],
    );
  }

  LatLng get latLng {
    try {
      final parts = coordinates.split(',');
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      return LatLng(lat, lng);
    } catch (_) {
      return const LatLng(-2.5489, 118.0149);
    }
  }

  String? get shakemapUrl => shakemap != null
  ? 'https//data.bmkg.go.id/DataMKG/TEWS/$shakemap'
  : null;
}

class BmkgEarthquakeBundle {
  final EarthquakeItem autoGempa;
  final List<EarthquakeItem> listGempaTerkini;

  BmkgEarthquakeBundle({
    required this.autoGempa,
    required this.listGempaTerkini,
  });
}