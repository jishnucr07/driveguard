part of 'sensor_data_cubit_cubit.dart';

@immutable
sealed class SensorDataCubitState {}

final class SensorDataCubitInitial extends SensorDataCubitState {}

final class SensorDatasentSuceessState extends SensorDataCubitState {
  final dynamic behaviour;

  SensorDatasentSuceessState(this.behaviour);
}

final class SensorDataInprogress extends SensorDataCubitState {}

final class SensorDataFail extends SensorDataCubitState {
  final dynamic error;

  SensorDataFail(this.error);
}
