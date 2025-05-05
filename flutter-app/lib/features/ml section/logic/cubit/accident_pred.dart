import 'package:bloc/bloc.dart';
import 'package:driveguard/features/ml%20section/logic/ml_repo.dart';
import 'package:meta/meta.dart';

@immutable
sealed class AccidentPredState {}

final class AccidentPredInitial extends AccidentPredState {}

final class AccidentPredSuccessState extends AccidentPredState {
  final double accidentPred;

  AccidentPredSuccessState(this.accidentPred);
}

final class AccidentPredInProgressState extends AccidentPredState {}

final class AccidentPredFailState extends AccidentPredState {
  final dynamic error;

  AccidentPredFailState(this.error);
}

class AccidentPredCubit extends Cubit<AccidentPredState> {
  AccidentPredCubit() : super(AccidentPredInitial());

  final MlRepo mlRepo = MlRepo();

  void accidentPrediction(Map<String, dynamic> inputData) async {
    try {
      emit(AccidentPredInProgressState());
      final dynamic res = await mlRepo.predictAccident(inputData);
      emit(AccidentPredSuccessState(res));
    } catch (e) {
      emit(AccidentPredFailState(e));
    }
  }
}
