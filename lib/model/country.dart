part of 'model.dart';

class Country extends Equatable {
  final String? countryId;
  final String? countryName;

  const Country({this.countryId, this.countryName});

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    countryId: json['country_id'] as String?,
    countryName: json['country_name'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'country_id': countryId,
    'country_name': countryName,
  };

  @override
  List<Object?> get props => [countryId, countryName];
}
