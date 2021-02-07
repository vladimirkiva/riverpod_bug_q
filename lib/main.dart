import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// everything is simplified
abstract class SuggestCompatibleState<T> {
  int get count;
}

abstract class SuggestCompatibleModel<T, S extends SuggestCompatibleState<T>> extends StateNotifier<S> {
  SuggestCompatibleModel(SuggestCompatibleState<T> state) : super(state);

  void add();
}

class User {
}

class UsersListState extends SuggestCompatibleState<User> {
  int _counter = 0;
  Map<String, User> _users = Map();

  @override
  int get count => _users.length;

  UsersListState copy() {
    return UsersListState()
        .._counter = _counter
        .._users = _users
    ;
  }
}

class UsersModel extends SuggestCompatibleModel<User, UsersListState> {
  UsersModel() : super(UsersListState());

  @override
  void add() {
    state._users[state._users.length.toString()] = User();
    state = state;
  }

  int value() {
    return state.count;
  }
}

class Refresher extends StateNotifier<int> {
  Refresher() : super(0);

  void refresh() {
    state = state++;
  }
}

final usersProvider = StateNotifierProvider<UsersModel>((_) => UsersModel());
final refreshProvider = StateNotifierProvider<Refresher>((_) => Refresher());

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    final model = context.read(usersProvider);
    // uncommenting this line forces to work without exception
    // watch(usersProvider.state);
    watch(refreshProvider.state);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: context.read(usersProvider).add,
                child: Text('increment')
            ),
            ElevatedButton(onPressed: context.read(refreshProvider).refresh, child: Text('refresh page')),
            Text(model.value().toString()),
            GenericWidget(usersProvider),
            if (model.value() > 5) ...[
              DirectWidget()
            ],
            Text('Press "increment" more then 5 times (say, 7) and then press "refresh page" to get exception'),
          ],
        ),
      ),
    );
  }
}

class GenericWidget<T> extends StatelessWidget {
  final StateNotifierProvider<SuggestCompatibleModel<T, SuggestCompatibleState<T>>> _provider;

  const GenericWidget(this._provider) : super();

  @override
  Widget build(BuildContext _) {
      return Consumer(builder: (context, watch, __) {
        final SuggestCompatibleState<T> state = watch(_provider.state);
        return Text(state.count.toString());
      }
    );
  }
}

class DirectWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, watch) {
    // Exception throws at this line
    // type 'StateNotifierStateProvider<SuggestCompatibleState<User>>' is not a subtype of type 'StateNotifierStateProvider<UsersListState>' in type cast
    final UsersListState state = watch(usersProvider.state);

    return Text(state.count.toString());
  }
}
