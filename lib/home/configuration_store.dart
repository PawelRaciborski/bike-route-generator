import 'dart:math';

import 'package:mobx/mobx.dart';

part 'configuration_store.g.dart';

class Configuration = _Configuration with _$Configuration;

abstract class _Configuration with Store {
  final random = Random();

  @observable
  double? latitude;

  @observable
  double? longitude;

  @observable
  bool locationMode = false;

  @computed
  bool get locationInputValid =>
      !locationMode || (latitude != null && longitude != null);

  @observable
  int length = 20;

  @observable
  int seed = 431;

  @action
  void refreshSeed() {
    seed = _generateNextSeed();
  }

  int _generateNextSeed() => random.nextInt(1000);

  @observable
  int points = 5;
}
