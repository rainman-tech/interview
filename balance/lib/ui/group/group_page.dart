import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/core/database/dao/transactions_dao.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage(this.groupId, {super.key});

  @override
  State<StatefulWidget> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final TransactionsDao _transactionsDao = getIt.get<TransactionsDao>();
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();

  final _transactionController = TextEditingController();
  final _editTransactionController = TextEditingController();

  late int balance = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final transactionAmount = await openDialog();
            if (transactionAmount == null) return;
            _transactionsDao.insert(transactionAmount, widget.groupId);
            _groupsDao.adjustBalance(
                balance + transactionAmount, widget.groupId);
          },
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '+ Add transaction',
            ),
          ),
        ),
        body: StreamBuilder(
          stream: _groupsDao.watchGroup(widget.groupId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }
            balance = snapshot.data?.balance ?? 0;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      snapshot.data?.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      snapshot.data?.balance.toString() ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 8),
                    child: Text("Transactions"),
                  ),
                  StreamBuilder(
                    stream:
                        _transactionsDao.watchGroupTransactions(widget.groupId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: Text("Loading..."));
                      }
                      if (snapshot.requireData.isEmpty) {
                        return const Center(
                          child: Text(
                            'No Transactions',
                          ),
                        );
                      }
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.requireData.length,
                        itemBuilder: (context, index) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(snapshot.requireData[index].amount
                                    .toString()),
                                const Spacer(),
                                Text(
                                  DateFormat('yyyy-MM-dd kk:mm').format(
                                    snapshot.requireData[index].createdAt,
                                  ),
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                GestureDetector(
                                  child: const Icon(
                                    Icons.edit,
                                    size: 16,
                                  ),
                                  onTap: () async {
                                    int oldAmount =
                                        snapshot.requireData[index].amount;
                                    _editTransactionController.text =
                                        oldAmount.toString();

                                    final newAmount =
                                        await editTransactionDialog();
                                    if (newAmount == null) return;
                                    _transactionsDao.adjustAmount(newAmount,
                                        snapshot.requireData[index].id);

                                    int adjustedBalance =
                                        (balance - oldAmount) + newAmount;
                                    _groupsDao.adjustBalance(
                                        adjustedBalance, widget.groupId);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 80,
                  )
                ],
              ),
            );
          },
        ),
      );

  Future<int?> openDialog() => showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Add transaction',
          ),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Amount'),
            controller: _transactionController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                submit(false);
              },
              child: const Text('Add expense'),
            ),
            TextButton(
              onPressed: () {
                submit(true);
              },
              child: const Text('Add income'),
            ),
          ],
        ),
      );

  void submit(bool isIncome) {
    if (isIncome) {
      Navigator.of(context).pop(int.parse(_transactionController.text));
    } else {
      Navigator.of(context).pop(-int.parse(_transactionController.text));
    }
    _transactionController.text = "";
  }

  Future<int?> editTransactionDialog() => showDialog<int>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Edit transaction',
          ),
          content: TextFormField(
            autofocus: true,
            controller: _editTransactionController,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                submitNewAmount();
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );

  void submitNewAmount() {
    Navigator.of(context).pop(int.parse(_editTransactionController.text));
    _editTransactionController.text = "";
  }
}
