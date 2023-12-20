import 'package:balance/core/database/dao/groups_dao.dart';
import 'package:balance/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GroupsDao _groupsDao = getIt.get<GroupsDao>();

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'GroupWallet',
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final name = await openDialog();
            if (name == null || name.isEmpty) return;
            _groupsDao.insert(name);
          },
          label: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '+ Add group',
            ),
          ),
        ),
        body: StreamBuilder(
          stream: _groupsDao.watch(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text("Loading...");
            }
            if (snapshot.requireData.isEmpty) {
              return const Center(
                child: Text(
                  'No Groups yet',
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.requireData.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        GoRouterHelper(context)
                            .push("/groups/${snapshot.requireData[index].id}");
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(snapshot.requireData[index].name),
                              Text(snapshot.requireData[index].balance
                                  .toString()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

  Future<String?> openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'Create group',
          ),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Group name'),
            controller: _controller,
          ),
          actions: [
            TextButton(
              onPressed: () {
                submit();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );

  void submit() {
    Navigator.of(context).pop(_controller.text);
    _controller.text = "";
  }
}
