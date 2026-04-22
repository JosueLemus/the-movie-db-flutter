import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_movie_db/features/movies/domain/entities/movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/usecases/get_movie_detail.dart';
import 'package:the_movie_db/features/movies/domain/usecases/is_favorite.dart';
import 'package:the_movie_db/features/movies/domain/usecases/toggle_favorite.dart';
import 'package:the_movie_db/features/movies/presentation/cubit/detail_state.dart';

class DetailCubit extends Cubit<DetailState> {
  DetailCubit({
    required GetMovieDetail getMovieDetail,
    required IsFavorite isFavorite,
    required ToggleFavorite toggleFavorite,
  })  : _getMovieDetail = getMovieDetail,
        _isFavorite = isFavorite,
        _toggleFavorite = toggleFavorite,
        super(const DetailState());

  final GetMovieDetail _getMovieDetail;
  final IsFavorite _isFavorite;
  final ToggleFavorite _toggleFavorite;

  Future<void> load(int movieId) async {
    emit(const DetailState());
    try {
      final results = await Future.wait<Object>([
        _getMovieDetail(movieId),
        _isFavorite(movieId),
      ]);
      emit(
        DetailState(
          status: DetailStatus.loaded,
          movieDetail: results[0] as MovieDetail,
          isFavorite: results[1] as bool,
        ),
      );
    } on Exception catch (e) {
      emit(DetailState(status: DetailStatus.error, error: e.toString()));
    }
  }

  Future<void> toggleFavorite() async {
    final detail = state.movieDetail;
    if (detail == null) return;
    await _toggleFavorite(detail.movie);
    emit(state.copyWith(isFavorite: !state.isFavorite));
  }
}
