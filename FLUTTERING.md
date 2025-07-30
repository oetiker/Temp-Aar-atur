# Flutter Style Guide for LLM Code Generation

## Core Philosophy
Generate Flutter code following Google's internal patterns: **prioritize simplicity, clarity, and maintainability over architectural complexity**. Only introduce complexity when genuinely needed.

## 1. Widget Architecture

### Widget Composition
**DO:** Use composition with small, focused widgets
```dart
// CORRECT: Small, focused widgets composed together
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ProductImage(imageUrl: product.imageUrl),
          ProductDetails(product: product),
          AddToCartButton(productId: product.id),
        ],
      ),
    );
  }
}
```

**DON'T:** Create complex inheritance hierarchies
```dart
// AVOID: Abstract base widgets with inheritance
abstract class BaseCard extends StatelessWidget {
  final EdgeInsets padding;
  const BaseCard({this.padding = EdgeInsets.zero});
  
  Widget buildContent(BuildContext context);
  // ... more abstract methods
}
```

### File Structure
**Rule:** One widget per file, named after the widget
```
✓ product_card.dart       → class ProductCard
✓ product_image.dart      → class ProductImage
✓ add_to_cart_button.dart → class AddToCartButton

✗ product_widgets.dart    → multiple widget classes
```

### Private Widget Methods
For widget-specific helper methods, use private methods with underscore prefix:
```dart
class ProductList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() => ListView(...);
  Widget _buildEmptyState() => Center(...);
  Widget _buildErrorState(String error) => ErrorWidget(...);
}
```

## 2. State Management

### Default to StatefulWidget
**Primary Rule:** Use StatefulWidget and setState() for UI state unless complexity genuinely demands more.

```dart
// PREFERRED for simple state
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('$_counter')),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### When to Use Advanced State Management
Only use Provider, Riverpod, Bloc, etc. when:
- State needs to be shared across multiple unrelated widgets
- State persists across navigation
- Complex async operations with multiple states
- Team explicitly requires it

## 3. Naming Conventions

### Methods: Action-Oriented
```dart
class UserService {
  // CORRECT: Concise, action-focused
  Future<User> fetch(String id) async {}
  Future<void> update(User user) async {}
  Future<void> delete(String id) async {}
  
  // AVOID: Redundant naming
  Future<User> fetchUserById(String id) async {}
  Future<void> updateUserProfile(User user) async {}
}
```

### When Context is Clear, Be Concise
```dart
// Inside CartService, context is clear
class CartService {
  Future<void> add(Product product) async {}     // Not addProductToCart
  Future<void> remove(String productId) async {} // Not removeProductFromCart
  Future<void> clear() async {}                  // Not clearCart
  Future<double> calculateTotal() async {}       // Not calculateCartTotal
}
```

### Add Clarity When Needed
```dart
class AuthService {
  Future<String> getAuthToken() async {}    // 'Token' alone might be ambiguous
  Future<User> getCurrentUser() async {}    // 'User' alone might be ambiguous
}
```

## 4. Error Handling

### Use Exceptions, Not Result Types
```dart
// CORRECT: Let exceptions bubble naturally
class ApiService {
  Future<User> getUser(String id) async {
    final response = await _client.get('/users/$id');
    
    if (response.statusCode != 200) {
      throw ApiException(
        'Failed to fetch user',
        statusCode: response.statusCode,
      );
    }
    
    return User.fromJson(response.data);
  }
}

// Usage: Handle at appropriate level
try {
  final user = await apiService.getUser(userId);
  // Use user
} on ApiException catch (e) {
  _showErrorSnackbar(e.message);
}
```

### Custom Exception Classes
```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(this.message, {this.statusCode, this.originalError});
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
```

## 5. Project Structure

### Feature-First Organization
```
lib/
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── login_form.dart
│   │   ├── auth_service.dart
│   │   └── user_model.dart
│   ├── products/
│   │   ├── product_list_screen.dart
│   │   ├── product_card.dart
│   │   ├── product_service.dart
│   │   └── product_model.dart
│   └── cart/
│       ├── cart_screen.dart
│       ├── cart_item.dart
│       ├── cart_service.dart
│       └── cart_model.dart
├── core/
│   ├── api/
│   │   └── api_client.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       └── error_view.dart
└── main.dart
```

## 6. Constants Organization

### Group by Context
```dart
// ui_constants.dart
class UiConstants {
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
}

// api_constants.dart  
class ApiConstants {
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}

// route_constants.dart
class Routes {
  static const String home = '/';
  static const String login = '/login';
  static const String productDetail = '/product/:id';
}
```

## 7. Model Classes

### Keep Models Simple
```dart
// CORRECT: Simple, immutable data class
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
    };
  }
}
```

## 8. Navigation

### Simple Direct Navigation
```dart
// PREFERRED: Direct navigation for simple cases
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(productId: product.id),
  ),
);

// Only use named routes when you need:
// - Deep linking
// - Complex navigation guards
// - Web URL support
```

## 9. Dependency Injection

### Constructor Injection for Simplicity
```dart
// CORRECT: Simple constructor injection
class ProductListScreen extends StatefulWidget {
  final ProductService productService;
  
  const ProductListScreen({
    super.key,
    ProductService? productService,
  }) : productService = productService ?? ProductService();
}

// For app-wide dependencies, use InheritedWidget or Provider
// but only when truly needed for cross-widget state sharing
```

## 10. Testing

### Focus on User Behavior
```dart
testWidgets('user can add product to cart', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProductCard(product: testProduct),
    ),
  );

  // User sees product details
  expect(find.text(testProduct.name), findsOneWidget);
  expect(find.text('\$${testProduct.price}'), findsOneWidget);

  // User taps add to cart
  await tester.tap(find.text('Add to Cart'));
  await tester.pump();

  // User sees confirmation
  expect(find.text('Added to cart'), findsOneWidget);
});
```

## 11. Performance Guidelines

### Build Methods Should Be Pure
```dart
class ProductCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // DON'T: Side effects in build
    // analytics.track('card_viewed'); ❌
    
    // DO: Keep build pure
    return Card(...);
  }
}
```

### Const Constructors Everywhere Possible
```dart
// Mark constructors const when all fields are final
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product}); // ✓
  final Product product;
}

// Use const for instantiation
const SizedBox(height: 16), // ✓
const Text('Hello'),        // ✓
```

## 12. Documentation

### Document Why, Not What
```dart
/// Fetches user data from the API.
/// 
/// Throws [ApiException] if the user is not found or the request fails.
/// We cache the result for 5 minutes to reduce API load during 
/// rapid screen transitions.
Future<User> fetchUser(String id) async {
  // Implementation
}
```

## Summary Decision Framework

When generating Flutter code, ask:

1. **Can this be solved with StatefulWidget?** → Use it
2. **Can this widget be smaller and more focused?** → Split it
3. **Is this abstraction solving a real problem?** → If not, remove it
4. **Will this name be clear in context?** → If yes, keep it concise
5. **Is this the simplest working solution?** → If not, simplify

Remember: Google's Flutter team can keep things simple because they deeply understand when complexity is needed. Default to simplicity, and only add complexity when the problem genuinely demands it.