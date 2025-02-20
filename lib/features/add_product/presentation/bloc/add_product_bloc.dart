import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Cubit<List<Category>> {
  final CategoryRepository categoryRepository;
  final SubCategoryRepository subCategoryRepository;

  // Update the constructor to accept both repositories
  AddProductBloc({
    required this.categoryRepository,
    required this.subCategoryRepository,
  }) : super([]);

  Future<void> loadCategories({required int layoutPosition}) async {
    try {
      // Use the updated fetchCategories method
      final categories = await categoryRepository.fetchCategories(
        layoutPosition: layoutPosition,
      );
      emit(categories);
    } catch (e) {
      emit([]); // Emit an empty list on error
      throw Exception('Failed to load categories: $e');
    }
  }
}
