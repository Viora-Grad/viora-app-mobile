import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viora_app/features/auth/data/datasources/local/auth_local.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthLocalDataSource _authLocal;

  HomeBloc({required AuthLocalDataSource authLocal})
      : _authLocal = authLocal,
        super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<ChangeCategoryEvent>((event, emit) {
      if (state is HomeLoaded) {
        emit((state as HomeLoaded).copyWith(selectedCategory: event.categoryName));
      }
    });
  }

  Future<void> _onLoadHomeData(LoadHomeDataEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final user = await _authLocal.getCurrentUser();
      final firstName = user?.firstName ?? '';
      emit(HomeLoaded(selectedCategory: 'Doctor', userName: firstName));
    } catch (_) {
      emit(const HomeLoaded(selectedCategory: 'Doctor', userName: ''));
    }
  }
}
