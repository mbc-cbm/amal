/// Prayer time calculation methods from the AlAdhan API.
/// id matches the AlAdhan `method` parameter.
class CalculationMethodData {
  const CalculationMethodData({
    required this.id,
    required this.name,
    required this.region,
    required this.tradition,
  });

  final int id;
  final String name;
  final String region;
  final String tradition; // 'sunni' | 'shia'
}

const List<CalculationMethodData> kSunniMethods = [
  CalculationMethodData(id: 2,  name: 'ISNA',                    region: 'Islamic Society of North America',           tradition: 'sunni'),
  CalculationMethodData(id: 3,  name: 'MWL',                     region: 'Muslim World League',                        tradition: 'sunni'),
  CalculationMethodData(id: 5,  name: 'Egyptian',                 region: 'Egyptian General Authority of Survey',       tradition: 'sunni'),
  CalculationMethodData(id: 4,  name: 'Umm al-Qura',             region: 'Umm al-Qura University, Makkah',             tradition: 'sunni'),
  CalculationMethodData(id: 1,  name: 'Karachi',                  region: 'University of Islamic Sciences, Karachi',    tradition: 'sunni'),
  CalculationMethodData(id: 8,  name: 'Gulf Region',              region: 'Gulf Region',                                tradition: 'sunni'),
  CalculationMethodData(id: 9,  name: 'Kuwait',                   region: 'Kuwait',                                     tradition: 'sunni'),
  CalculationMethodData(id: 10, name: 'Qatar',                    region: 'Qatar',                                      tradition: 'sunni'),
  CalculationMethodData(id: 15, name: 'Moonsighting Committee',   region: 'Moonsighting Committee Worldwide',           tradition: 'sunni'),
  CalculationMethodData(id: 13, name: 'Turkey',                   region: 'Diyanet İşleri Başkanlığı, Turkey',          tradition: 'sunni'),
  CalculationMethodData(id: 14, name: 'Russia',                   region: 'Spiritual Administration of Muslims of Russia', tradition: 'sunni'),
  CalculationMethodData(id: 16, name: 'Dubai',                    region: 'Dubai, UAE',                                 tradition: 'sunni'),
];

const List<CalculationMethodData> kShiaMethods = [
  CalculationMethodData(id: 7, name: 'Tehran', region: 'Institute of Geophysical Research, Tehran', tradition: 'shia'),
];

List<CalculationMethodData> methodsForTradition(String tradition) =>
    tradition == 'shia' ? kShiaMethods : kSunniMethods;
