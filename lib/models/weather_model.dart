class LocationInfo {
  final String desa;
  final String kecamatan;
  final String kotkab;
  final String provinsi;

  LocationInfo({
    required this.desa,
    required this.kecamatan,
    required this.kotkab,
    required this.provinsi,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      desa: json['desa']?.toString() ?? '-',
      kecamatan: json['kecamatan']?.toString() ?? '-',
      kotkab: json['kotkab']?.toString() ?? '-',
      provinsi: json['provinsi']?.toString() ?? '-',
    );
  }
}

class WeatherItem {
  final String localDatetime;
  final int temperature;
  final int humidity;
  final String weatherDesc;
  final double windSpeed;
  final String windDirection;
  final int cloudCover;
  final String visibilityText;

  WeatherItem({
    required this.localDatetime,
    required this.temperature,
    required this.humidity,
    required this.weatherDesc,
    required this.windSpeed,
    required this.windDirection,
    required this.cloudCover,
    required this.visibilityText,
  });

  factory WeatherItem.fromJson(Map<String, dynamic> json) {
    String rawTime = (json['local_datetime'] ??
        json['datetime'] ??
        json['utc_datetime'] ??
        json['analysis_date'] ??
        '')
        .toString()
        .trim();

    if (rawTime.contains('T')) {
      rawTime = rawTime.replaceAll('T', ' ').replaceAll('Z', '');
    }
    if (rawTime.length > 16) {
      rawTime = rawTime.substring(0, 16);
    }
    if (rawTime.isEmpty) {
      rawTime = 'Update Berkala (Per 3 Jam)';
    }

    String rawVis = (json['vs_text'] ?? '').toString().trim();
    if (rawVis.isEmpty || rawVis == '-') {
      if (json['vs'] != null) {
        final num? vsNum = num.tryParse(json['vs'].toString());
        if (vsNum != null) {
          rawVis = vsNum >= 1000
              ? '${(vsNum / 1000).toStringAsFixed(1)} km'
              : '$vsNum m';
        } else {
          rawVis = '${json['vs']} km';
        }
      } else {
        rawVis = '> 10 km';
      }
    }

    return WeatherItem(
      localDatetime: rawTime,
      temperature: (json['t'] as num?)?.toInt() ??
          int.tryParse(json['t']?.toString() ?? '0') ??
          0,
      humidity: (json['hu'] as num?)?.toInt() ??
          int.tryParse(json['hu']?.toString() ?? '0') ??
          0,
      weatherDesc: (json['weather_desc'] ?? json['weather_desc_en'] ?? 'Cerah')
          .toString(),
      windSpeed: (json['ws'] as num?)?.toDouble() ??
          double.tryParse(json['ws']?.toString() ?? '0') ??
          0.0,
      windDirection: (json['wd'] ?? '-').toString(),
      cloudCover: (json['tcc'] as num?)?.toInt() ??
          int.tryParse(json['tcc']?.toString() ?? '0') ??
          0,
      visibilityText: rawVis,
    );
  }
}

class BmkgWeatherResponse {
  final LocationInfo lokasi;
  final List<WeatherItem> listCuaca;

  BmkgWeatherResponse({
    required this.lokasi,
    required this.listCuaca,
  });

  factory BmkgWeatherResponse.fromJson(Map<String, dynamic> json) {
    final dataObj = json['data'][0];
    final lokasiInfo =
    LocationInfo.fromJson(dataObj['lokasi'] ?? json['lokasi'] ?? {});

    final List<dynamic> rawCuaca = dataObj['cuaca'] ?? [];
    final List<WeatherItem> flattenedCuaca = [];

    for (final elemen in rawCuaca) {
      if (elemen is List) {
        for (final subItem in elemen) {
          if (subItem is Map<String, dynamic>) {
            flattenedCuaca.add(WeatherItem.fromJson(subItem));
          }
        }
      } else if (elemen is Map<String, dynamic>) {
        flattenedCuaca.add(WeatherItem.fromJson(elemen));
      }
    }

    return BmkgWeatherResponse(
      lokasi: lokasiInfo,
      listCuaca: flattenedCuaca,
    );
  }
}