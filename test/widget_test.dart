import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

final usersProvider = StateNotifierProvider<UsersModel, UsersListState>((_) => UsersModel());

void main() {
  test('Runtime exception', () {
    final container = ProviderContainer();
    final StateNotifierProvider<SuggestCompatibleModel<User, SuggestCompatibleState<User>>, SuggestCompatibleState<User>> _provider = usersProvider;

    container.read(_provider);


    // Exception is thrown at the next line. Expected to pass without exception
    // type 'StateNotifierStateProvider<SuggestCompatibleState<dynamic>>' is not a subtype of type 'StateNotifierStateProvider<UsersListState>' in type cast
    container.read(usersProvider);
  });
}
