class PickerModel<T> {
  final String? name;
  final List<T> selected;
  final List<T> data;

  PickerModel({
    this.name,
    required this.selected,
    required this.data,
  });
}
