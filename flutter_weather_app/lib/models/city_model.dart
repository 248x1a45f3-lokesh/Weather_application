/// Model representing a city with coordinates and country details.
class CityModel {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? state;
  final bool isFavorite;

  const CityModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.state,
    this.isFavorite = false,
  });

  CityModel copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? state,
    bool? isFavorite,
  }) {
    return CityModel(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      state: state ?? this.state,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'state': state,
      'isFavorite': isFavorite,
    };
  }

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String? ?? 'Unknown City',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      country: json['country'] as String? ?? '',
      state: json['state'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityModel &&
          runtimeType == other.runtimeType &&
          name.toLowerCase() == other.name.toLowerCase() &&
          country.toLowerCase() == other.country.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode ^ country.toLowerCase().hashCode;
}
