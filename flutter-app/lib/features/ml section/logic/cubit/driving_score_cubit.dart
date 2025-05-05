import 'package:driveguard/features/ml%20section/logic/ml_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DrivingScoreState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DrivingScoreInitial extends DrivingScoreState {}

class DrivingScoreLoading extends DrivingScoreState {}

class DrivingScoreSuccess extends DrivingScoreState {
  final double drivingScore;

  DrivingScoreSuccess(this.drivingScore);

  @override
  List<Object?> get props => [drivingScore];
}

class DrivingScoreError extends DrivingScoreState {
  final String message;

  DrivingScoreError(this.message);

  @override
  List<Object?> get props => [message];
}

class DrivingScoreCubit extends Cubit<DrivingScoreState> {
  DrivingScoreCubit() : super(DrivingScoreInitial());

  final MlRepo mlRepo = MlRepo();
  Future<void> calculateScore({
    required double maxSpeed,
    required double speedLimit,
    required double accidentPercentage,
  }) async {
    try {
      // Call the API to calculate the driver score
      final score = await mlRepo.calculateDriverScore(
        maxSpeed: maxSpeed,
        speedLimit: speedLimit,
        accidentPercentage: accidentPercentage,
      );

      // Emit the calculated score
      emit(DrivingScoreSuccess(score));
    } catch (e) {
      emit(DrivingScoreError(e.toString()));
    }
  }
}
