enum ViewState { initial, loading, success, error }

class BaseState<T> {
  final ViewState status;
  final T? data;
  final String? errorMessage;

  BaseState({
    this.status = ViewState.initial,
    this.data,
    this.errorMessage,
  });

  BaseState<T> copyWith({
    ViewState? status,
    T? data,
    String? errorMessage,
  }) {
    return BaseState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
