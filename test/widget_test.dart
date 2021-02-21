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

class MockWidget<T> {
  final StateNotifierProvider<SuggestCompatibleModel<T, SuggestCompatibleState<T>>> _provider;

  MockWidget(this._provider);

  read(ProviderContainer container) {
    container.read(_provider.state);
  }
}

void main() {
  test('Generic read', () {
    final container = ProviderContainer();
    final MockWidget w = MockWidget(usersProvider);
    w.read(container);
    // Exception is thrown here. Expected to pass without exception
    //  type 'StateNotifierStateProvider<SuggestCompatibleState<dynamic>>' is not a subtype of type 'StateNotifierStateProvider<UsersListState>' in type cast
    container.read(usersProvider.state);
  });
}
