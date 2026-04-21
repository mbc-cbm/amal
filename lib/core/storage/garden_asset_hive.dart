import 'package:hive/hive.dart';

/// Hive model for a placed garden asset.
/// Manual TypeAdapter used because hive_generator is incompatible
/// with riverpod_generator's analyzer version.
class GardenAssetHive extends HiveObject {
  GardenAssetHive({
    this.assetTemplateId = '',
    this.slotKey = '',
    this.positionX = 0,
    this.positionY = 0,
    this.tier = 'common',
    this.isDiscovered = false,
    this.currentHealthState = 1,
    this.originalNcPrice = 0,
    this.purchaseType = 'nc',
    this.isPlaced = false,
    this.purchasedAtMs = 0,
  });

  late String assetTemplateId;
  late String slotKey; // "x,y" format
  late double positionX;
  late double positionY;
  late String tier;
  late bool isDiscovered;
  late int currentHealthState; // 1-5
  late int originalNcPrice;
  late String purchaseType; // 'nc' | 'discovered'
  late bool isPlaced;
  late int purchasedAtMs; // millisecondsSinceEpoch

  Map<String, dynamic> toMap() => {
        'assetTemplateId': assetTemplateId,
        'slotKey': slotKey,
        'positionX': positionX,
        'positionY': positionY,
        'tier': tier,
        'isDiscovered': isDiscovered,
        'currentHealthState': currentHealthState,
        'originalNcPrice': originalNcPrice,
        'purchaseType': purchaseType,
        'isPlaced': isPlaced,
        'purchasedAtMs': purchasedAtMs,
      };

  factory GardenAssetHive.fromMap(Map<String, dynamic> map) {
    return GardenAssetHive(
      assetTemplateId: map['assetTemplateId'] as String? ?? '',
      slotKey: map['slotKey'] as String? ?? '',
      positionX: (map['positionX'] as num?)?.toDouble() ?? 0,
      positionY: (map['positionY'] as num?)?.toDouble() ?? 0,
      tier: map['tier'] as String? ?? 'common',
      isDiscovered: map['isDiscovered'] as bool? ?? false,
      currentHealthState: (map['currentHealthState'] as num?)?.toInt() ?? 1,
      originalNcPrice: (map['originalNcPrice'] as num?)?.toInt() ?? 0,
      purchaseType: map['purchaseType'] as String? ?? 'nc',
      isPlaced: map['isPlaced'] as bool? ?? false,
      purchasedAtMs: (map['purchasedAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}

// ── Manual Hive TypeAdapter (typeId: 10) ─────────────────────────────────

class GardenAssetHiveAdapter extends TypeAdapter<GardenAssetHive> {
  @override
  final int typeId = 10;

  @override
  GardenAssetHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GardenAssetHive(
      assetTemplateId: fields[0] as String? ?? '',
      slotKey: fields[1] as String? ?? '',
      positionX: (fields[2] as num?)?.toDouble() ?? 0,
      positionY: (fields[3] as num?)?.toDouble() ?? 0,
      tier: fields[4] as String? ?? 'common',
      isDiscovered: fields[5] as bool? ?? false,
      currentHealthState: (fields[6] as num?)?.toInt() ?? 1,
      originalNcPrice: (fields[7] as num?)?.toInt() ?? 0,
      purchaseType: fields[8] as String? ?? 'nc',
      isPlaced: fields[9] as bool? ?? false,
      purchasedAtMs: (fields[10] as num?)?.toInt() ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, GardenAssetHive obj) {
    writer
      ..writeByte(11) // number of fields
      ..writeByte(0)
      ..write(obj.assetTemplateId)
      ..writeByte(1)
      ..write(obj.slotKey)
      ..writeByte(2)
      ..write(obj.positionX)
      ..writeByte(3)
      ..write(obj.positionY)
      ..writeByte(4)
      ..write(obj.tier)
      ..writeByte(5)
      ..write(obj.isDiscovered)
      ..writeByte(6)
      ..write(obj.currentHealthState)
      ..writeByte(7)
      ..write(obj.originalNcPrice)
      ..writeByte(8)
      ..write(obj.purchaseType)
      ..writeByte(9)
      ..write(obj.isPlaced)
      ..writeByte(10)
      ..write(obj.purchasedAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GardenAssetHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
