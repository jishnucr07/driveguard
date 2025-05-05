import 'package:driveguard/features/home/presentation/ui/services/weather_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final WeatherService weatherService;

  WeatherCubit(this.weatherService) : super(WeatherInitial());

  Future<void> fetchWeather(double lat, double lon) async {
    emit(WeatherLoading());
    try {
      final weather = await weatherService.getWeather(lat, lon);
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> featchHourlyWeather(double lat, double lon) async {
    emit(WeatherLoading());
    try {
      final hourlyWeather = await weatherService.getHourlyWeather(lat, lon);
      emit(WeatherLoaded(hourlyWeather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}

abstract class WeatherState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Map<String, dynamic> weather;

  WeatherLoaded(this.weather);

  @override
  List<Object?> get props => [weather];
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}
