import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeMoviesRequested extends HomeEvent {
  const HomeMoviesRequested(this.genreId);

  final int genreId;

  @override
  List<Object?> get props => [genreId];
}
