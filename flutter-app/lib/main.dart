import 'package:driveguard/common/hive/trip_data_hive_model.dart';
import 'package:driveguard/common/hive/type_adapters_map_data.dart';
import 'package:driveguard/features/auth/logic/auth_cubit.dart';
import 'package:driveguard/features/auth/logic/auth_repo.dart';
import 'package:driveguard/features/auth/ui/login_page.dart';
import 'package:driveguard/features/home/presentation/ui/home_page.dart';
import 'package:driveguard/features/home/presentation/ui/services/cubit/road_cubit.dart';
import 'package:driveguard/features/home/presentation/ui/services/cubit/weather_cubit.dart';
import 'package:driveguard/features/home/presentation/ui/services/road_service.dart';
import 'package:driveguard/features/home/presentation/ui/services/weather_service.dart';
import 'package:driveguard/features/map/map_page.dart';
import 'package:driveguard/features/ml%20section/logic/cubit/accident_pred.dart';
import 'package:driveguard/features/ml%20section/logic/cubit/driving_score_cubit.dart';
import 'package:driveguard/features/ml%20section/logic/cubit/sensor_data_cubit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://urhfcyaxygjjaxvhqtca.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVyaGZjeWF4eWdqamF4dmhxdGNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzgxMzk0MzEsImV4cCI6MjA1MzcxNTQzMX0.ohLpBAU6WvPBVeyPt6SRQXoFi13u_XeVY-HVnIAJRUw',
  );
  final appDocumentDirectory =
      await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  // Register adapters
  Hive.registerAdapter(TripDataAdapter());
  Hive.registerAdapter(MapAdapter());

  // Open the box
  await Hive.openBox<TripData>('trip_history');
  // final authRepo = AuthRepo(supabaseClient: Supabase.instance.client);
  // await authRepo.restoreSession();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => SensorDataCubitCubit(),
      ),
      BlocProvider(
        create: (context) => DrivingScoreCubit(),
      ),
      BlocProvider(
        create: (context) =>
            WeatherCubit(WeatherService('f61e8249ba643a28748205d6a232b577')),
      ),
      BlocProvider(
        create: (context) => RoadCubit(RoadService()),
      ),
      BlocProvider(
        create: (context) => AccidentPredCubit(),
      ),
      BlocProvider(
        create: (context) => AuthCubit(
            authRepo: AuthRepo(supabaseClient: Supabase.instance.client)),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: AppBarTheme(backgroundColor: Colors.black),
          // scaffoldBackgroundColor: Colors.black,
          textTheme: TextTheme(
            titleMedium: GoogleFonts.poppins(
              color: Colors.white,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthCubit, AuthStates>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return HomePage();
            } else {
              return LoginPage();
              // } else if (state is AuthError) {
              //   return ErrorPage(message: state.message);
              // } else {
            }
          },
        ));
  }
}
