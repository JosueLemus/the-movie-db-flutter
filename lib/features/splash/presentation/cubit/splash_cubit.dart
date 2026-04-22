import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_movie_db/features/splash/domain/usecases/initialize_app.dart';
import 'package:the_movie_db/features/splash/presentation/cubit/splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._initializeApp) : super(const SplashInitial());

  final InitializeApp _initializeApp;

  Future<void> initialize() async {
    emit(const SplashLoading());

    final result = await _initializeApp();

    if (result.isMaintenanceMode) {
      emit(const SplashMaintenanceMode());
      return;
    }

    emit(SplashReady(welcomeMessage: result.welcomeMessage));
  }
}
