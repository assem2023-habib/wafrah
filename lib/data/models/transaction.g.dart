part of 'transaction.dart';

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 2;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[6] as String,
      type: fields[0] as TransactionType,
      amount: fields[1] as double,
      categoryId: fields[2] as String?,
      productId: fields[3] as String?,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(6)
      ..write(obj.id)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.productId)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 11;

  @override
  TransactionType read(BinaryReader reader) =>
      TransactionType.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, TransactionType obj) =>
      writer.writeByte(obj.index);

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}