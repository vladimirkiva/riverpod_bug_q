import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// everything is simplified
abstract class SuggestCompatibleState<T> {
}

abstract class SuggestCompatibleModel<T, S extends SuggestCompatibleState<T>> extends StateNotifier<S> {
  SuggestCompatibleModel(SuggestCompatibleState<T> state) : super(state);
}

class User {
}

class UsersListState extends SuggestCompatibleState<User> {
}

class UsersModel extends SuggestCompatibleModel<User, UsersListState> {
  UsersModel() : super(UsersListState());
}

final usersProvider = StateNotifierProvider<UsersModel>((_) => UsersModel());

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
