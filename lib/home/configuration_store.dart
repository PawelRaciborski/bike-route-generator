import 'package:mobx/mobx.dart';

part 'configuration_store.g.dart';

class Configuration = _Configuration with _$Configuration;

abstract class _Configuration with Store {
  @observable
  double? latitude;

  @observable
  double? longitude;

  @computed
  bool get locationValid => latitude != null && longitude != null;
}
