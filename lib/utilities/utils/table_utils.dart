class PaginatedDataTableSource<T> {
  final int rowsPerPage;
  final int page;
  final int totalRows;
  final List<T> data;

  PaginatedDataTableSource({
    required this.rowsPerPage,
    required this.page,
    required this.totalRows,
    required this.data,
  });

  int get startRow => (page - 1) * rowsPerPage + 1;
  int get endRow => (page * rowsPerPage).clamp(1, totalRows);
}
