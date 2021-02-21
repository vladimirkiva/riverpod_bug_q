import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';


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
  Map<String, User> _users = Map();

  @override
  int get count => _users.length;

  UsersListState copy() {
    return UsersListState()
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

const Key keyIncrement = ValueKey('increment');
const Key keySwitch = ValueKey('switch');
const Key keyCounter = ValueKey('counter');

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
              key: keyIncrement,
              onPressed: context.read(usersProvider).add,
              child: Text('increment')
            ),
            ElevatedButton(
                key: keySwitch,
                onPressed: context.read(refreshProvider).refresh,
                child: Text('refresh page')
            ),
            Text(model.value().toString()),
            GenericWidget(usersProvider),
            if (model.value() > 0) ...[
              DirectWidget()
            ],
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
      return Text(state.count.toString(), key: keyCounter);
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

void main() {
  testWidgets('Generic', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: MaterialApp(
      home: MyHomePage(),
    )));

    var byKey = find.byKey(keyCounter);
    Text firstWidget = tester.firstWidget(byKey);
    expect(firstWidget.data, '0');
    await tester.tap(find.byKey(keyIncrement));
    await tester.pump();

    firstWidget = tester.firstWidget(find.byKey(keyCounter));
    expect(firstWidget.data, '1');

    await tester.tap(find.byKey(keySwitch));
    // Exception is thrown here! Expected to pass the test without exception
    await tester.pump();
  });
}
