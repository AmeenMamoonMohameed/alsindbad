class PaginationModel {
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final int totalCount;

  PaginationModel({
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.totalCount,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}
