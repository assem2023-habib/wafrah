import '../../models/transaction.dart';

abstract class ITransactionRepository {
  Future<List<Transaction>> getAll();

  Future<Transaction?> getById(String id);

  Future<Transaction> add(Transaction transaction);

  Future<void> update(Transaction transaction);

  Future<void> delete(String id);
}