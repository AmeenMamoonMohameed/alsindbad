enum MessageType {
  text,
  image,

  /// Only supported on android and ios
  voice,
  question,
  map,
  custom
}

enum ChatViewState { hasMessages, noData, loading, error }

extension ChatViewStateExtension on ChatViewState {
  bool get hasMessages => this == ChatViewState.hasMessages;

  bool get isLoading => this == ChatViewState.loading;

  bool get isError => this == ChatViewState.error;

  bool get noMessages => this == ChatViewState.noData;
}
