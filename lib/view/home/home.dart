import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_frame/controller/product_controller.dart';
import 'package:project_frame/core/component/custom_error_widget.dart';
import 'package:project_frame/core/utils/context_extension.dart';
import 'package:project_frame/models/response_models/product_model.dart';
import 'package:project_frame/view/theme/swith_theme.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductsController productsController = Get.find();

  @override
  void initState() {
    super.initState();
    // Load products on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productsController.getAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FakeStore",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          ThemeSwitch(),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              productsController.testError();
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (productsController.isLoading.value) {
          return _buildSkeletonLoader();
        }

        if (productsController.errorMessage.isNotEmpty) {
          return CustomErrorWidget(
            errorText: productsController.errorMessage.value,
            onRetry: () {
              productsController.getAllProducts();
            },
          );
        }

        return _buildProductGrid(productsController.products);
      }),
    );
  }

  Widget _buildSkeletonLoader() {
    // Create a list of empty products for skeleton loading
    final skeletonProducts = List<ProductModel>.generate(
      6,
      (index) => ProductModel(
        id: 0,
        title: '',
        price: 0,
        description: '',
        category: '',
        image: '',
        rating: Rating(rate: 0, count: 0),
      ),
    );

    return _buildProductGrid(skeletonProducts);
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        final horizontalPadding = _getHorizontalPadding(constraints.maxWidth);
        final cardPadding = _getCardPadding(constraints.maxWidth);
        final aspectRatio = _getAspectRatio(constraints.maxWidth);

        return Container(
          margin: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: horizontalPadding,
          ),
          child: CustomRefreshIndicator(
            onRefresh: () async {
              await productsController.getAllProducts();
            },
            builder: (BuildContext context, Widget child,
                IndicatorController controller) {
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  // Your GridView
                  child,

                  // Refresh indicator
                  if (controller.isDragging || controller.isArmed)
                    Positioned(
                      top: 10,
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) {
                          return Transform.rotate(
                            angle: controller.value * 2 * 3.14,
                            child: const Icon(Icons.refresh, size: 28),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: aspectRatio,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _ProductCard(
                  product: products[index],
                  padding: cardPadding,
                );
              },
            ),
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth > 1600) return 6;
    if (screenWidth > 1200) return 5;
    if (screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth > 1600) return 200;
    if (screenWidth > 1200) return 100;
    if (screenWidth > 900) return 60;
    if (screenWidth > 600) return 30;
    return 16;
  }

  double _getAspectRatio(double screenWidth) {
    if (screenWidth > 1600) return 0.85;
    if (screenWidth > 1200) return 0.8;
    if (screenWidth > 900) return 0.75;
    if (screenWidth > 600) return 0.7;
    return 0.65;
  }

  EdgeInsets _getCardPadding(double screenWidth) {
    if (screenWidth > 1600) return const EdgeInsets.all(20);
    if (screenWidth > 1200) return const EdgeInsets.all(16);
    if (screenWidth > 900) return const EdgeInsets.all(14);
    if (screenWidth > 600) return const EdgeInsets.all(12);
    return const EdgeInsets.all(10);
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final EdgeInsets padding;

  const _ProductCard({
    required this.product,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to product detail page (add Get.to or Navigator)
        },
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                child: Center(
                  child: product.image.isEmpty
                      ? Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.category.isEmpty
                      ? ''
                      : product.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Product title
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Price and rating row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.price == 0
                        ? ''
                        : '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.rate == 0
                            ? ''
                            : product.rating.rate.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
