import 'package:hive/hive.dart';

import '../../models/transaction.dart';
import '../interfaces/transaction_repository_interface.dart';

class HiveTransactionRepository implements ITransactionRepository {
  Box<Transaction> get _box => Hive.box<Transaction>('transactions');

  @override
  Future<List<Transaction>> getAll() async => _box.values.toList();

  @override
  Future<Transaction?> getById(String id) async {
    for (final key in _box.keys) {
      final transaction = _box.get(key);
      if (transaction != null && transaction.id == id) return transaction;
    }
    return null;
  }

  @override
  Future<Transaction> add(Transaction transaction) async {
    await _box.add(transaction);
    return transaction;
  }

  @override
  Future<void> update(Transaction transaction) async {
    for (final key in _box.keys) {
      final existing = _box.get(key);
      if (existing != null && existing.id == transaction.id) {
        await _box.put(key, transaction);
        return;
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    for (final key in _box.keys) {
      final existing = _box.get(key);
      if (existing != null && existing.id == id) {
        await _box.delete(key);
        return;
      }
    }
  }
}