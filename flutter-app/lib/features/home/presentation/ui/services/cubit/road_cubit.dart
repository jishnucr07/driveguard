import 'package:driveguard/features/home/presentation/ui/services/road_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class RoadCubit extends Cubit<RoadState> {
  final RoadService roadService;

  RoadCubit(this.roadService) : super(RoadInitial());

  Future<void> fetchRoadData(double lat, double lon) async {
    emit(RoadLoading());
    try {
      final road = await roadService.getRoadData(lat, lon);
      emit(RoadLoaded(road));
    } catch (e) {
      emit(RoadError(e.toString()));
    }
  }
}

abstract class RoadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RoadInitial extends RoadState {}

class RoadLoading extends RoadState {}

class RoadLoaded extends RoadState {
  final Map<String, dynamic> road;

  RoadLoaded(this.road);

  @override
  List<Object?> get props => [road];
}

class RoadError extends RoadState {
  final String message;

  RoadError(this.message);

  @override
  List<Object?> get props => [message];
}
