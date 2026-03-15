
import '../entities/product.dart';

abstract class ProductRepository {
  /// Fetches all available products (usually paginated in real apps)
  Future<List<Product>> getProducts();

  /// Fetches a single product by its ID
  Future<Product> getProductById(String id);

  /// Fetches products based on a category
  Future<List<Product>> getProductsByCategory(String categoryId);
}