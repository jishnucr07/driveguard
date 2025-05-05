import 'package:bloc/bloc.dart';
import 'package:driveguard/features/ml%20section/logic/ml_repo.dart';
import 'package:flutter/material.dart';

part 'sensor_data_cubit_state.dart';

class SensorDataCubitCubit extends Cubit<SensorDataCubitState> {
  SensorDataCubitCubit() : super(SensorDataCubitInitial());

  final MlRepo mlRepo = MlRepo();

  void sendSensorData(List<List<double>> sensorData) async {
    try {
      emit(SensorDataInprogress());
      final dynamic res = await mlRepo.sendSensorData(sensorData);
      emit(SensorDatasentSuceessState(res));
    } catch (e) {
      emit(SensorDataFail(e));
    }
  }
}
