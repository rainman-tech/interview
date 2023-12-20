import 'package:balance/core/database/database.dart';
import 'package:balance/core/database/tables/transactions.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'transactions_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<Database>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future insert(int amount, String id) {
    return into(transactions).insert(
      TransactionsCompanion.insert(
        id: const Uuid().v1(),
        createdAt: DateTime.now(),
        amount: Value(amount),
        groupId: id,
      ),
    );
  }

  Future adjustAmount(int amount, String transactionId) async {
    final companion = TransactionsCompanion(amount: Value(amount));
    return (update(transactions)..where((tbl) => tbl.id.equals(transactionId)))
        .write(companion);
  }

  Stream<List<Transaction>> watchGroupTransactions(String groupId) {
    return (select(transactions)..where((tbl) => tbl.groupId.equals(groupId)))
        .watch();
  }
}
