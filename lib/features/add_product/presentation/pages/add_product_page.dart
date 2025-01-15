import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gehnaorg/features/add_product/data/models/category.dart';
import 'package:gehnaorg/features/add_product/data/models/post.dart';
import 'package:gehnaorg/features/add_product/data/models/subcategory.dart';
import 'package:gehnaorg/features/add_product/data/repositories/category_repository.dart';
import 'package:gehnaorg/features/add_product/data/repositories/subcategory_repository.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/add_product_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/login_bloc.dart';
import 'package:gehnaorg/features/add_product/presentation/bloc/subcategory_bloc/subcategory_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/constants.dart';
import '../../apis/gifting_service.dart';
import '../../apis/occasions.dart';
import '../../apis/soulmates_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _wastageController = TextEditingController();
  final _weightController = TextEditingController();

  Category? _selectedCategory;
  SubCategory? _selectedSubCategory;
  int? _selectedGender;
  String? _selectedKarat = '18K';

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];

  Future<void> _pickImages(ImageSource source) async {
    print("Picking images from gallery...");
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null &&
        _selectedImages.length + pickedImages.length <= 7) {
      print("Picked ${pickedImages.length} images.");
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    } else {
      print("Exceeded image limit. Showing error message.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select a maximum of 7 images.')),
      );
    }
  }

  List<String> _soulmateOptions = [];
  bool _isLoadingSoulmateOptions = true;
  String? _selectedSoulmate;

  void _loadSoulmateOptions() async {
    try {
      final options = await SoulmateService().fetchSoulmateOptions();
      setState(() {
        _soulmateOptions = options;
        _isLoadingSoulmateOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSoulmateOptions = false;
      });
      print('Error fetching soulmate options: $e');
    }
  }

  List<String> _occasionOptions = [];
  bool _isLoadingOccasionOptions = true;
  String? _selectedOccasion;

  @override
  void initState() {
    super.initState();
    _loadGiftingOptions();
    _loadOccasionOptions();
    _loadSoulmateOptions();
  }

  void _loadOccasionOptions() async {
    try {
      final options = await OccasionService().fetchOccasionOptions();
      setState(() {
        _occasionOptions = options;
        _isLoadingOccasionOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOccasionOptions = false;
      });
      print('Error fetching occasion options: $e');
    }
  }

  List<String> _giftingOptions = [];
  bool _isLoadingGiftingOptions = true;
  String? _selectedGifting;

  void _loadGiftingOptions() async {
    try {
      final options = await GiftingService().fetchGiftingOptions();
      setState(() {
        _giftingOptions = options;
        _isLoadingGiftingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGiftingOptions = false;
      });
      print('Error fetching gifting options: $e');
    }
  }

  // Function to capture an image from camera
  Future<void> _captureImage() async {
    print("Capturing image from camera...");
    if (_selectedImages.length >= 7) {
      print("Exceeded image limit. Showing error message.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can select a maximum of 7 images.')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      print("Captured image: ${image.path}");
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  // Function to remove a selected image
  void _removeImage(int index) {
    print("Removing image at index: $index");
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
//
//

//
//
//
  Future<void> _submitProduct() async {
    print("Starting product submission...");

    // Step 1: Validate form fields
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed.");
      return;
    }

    // Step 2: Validate image selection (1 to 7 images allowed)
    if (_selectedImages.isEmpty || _selectedImages.length > 7) {
      print(
          "Invalid image selection: ${_selectedImages.length} images selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select between 1 and 7 images.')),
      );
      return;
    }

    // Step 3: Validate category selection
    if (_selectedCategory == null) {
      print("Category not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category is required!')),
      );
      return;
    }

    // Step 4: Check if user is logged in
    final loginState = context.read<LoginBloc>().state;
    if (loginState is! LoginSuccess) {
      print("User not logged in.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue.')),
      );
      return;
    }

    // Get token and identity from login state
    final String token = loginState.login.token;
    final String identity = loginState.login.identity;

    // Step 5: Get Wholesaler ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final int? wholesalerId = prefs.getInt('wholesalerId');
    if (wholesalerId == null) {
      print("Wholesaler ID not found in SharedPreferences.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to retrieve wholesaler information.')),
      );
      return;
    }

    // Step 6: Prepare the product upload request data
    var uploadRequest = ProductUploadRequest(
      productName: _productNameController.text,
      description: _descriptionController.text,
      wastage: _wastageController.text,
      weight: _weightController.text,
      karat: _selectedKarat!,
      categoryName: _selectedCategory!.categoryName,
      categoryId: _selectedCategory!.categoryId.toString(),
      subCategoryName: _selectedSubCategory?.subCategoryName ?? '',
      subCategoryId: _selectedSubCategory?.subcategoryId.toString() ?? '',
      tagNumber: '',
      length: '',
      size: '',
      wholesaler: identity,
      wholesalerId: wholesalerId.toString(),
      occasion: _selectedOccasion ?? '',
      soulmate: _selectedSoulmate ?? '',
      gifting: _selectedGifting ?? '',
      gender: _selectedGender == 1 ? 'Male' : 'Female',
      productType: '',
    );

    // Step 7: Upload the product
    await uploadProduct(token, uploadRequest);
  }

  Future<void> uploadProduct(
      String token, ProductUploadRequest uploadRequest) async {
    var uri = Uri.parse(
        'https://upload-service-254137058023.asia-south1.run.app/upload/product');

    // Step 8: Serialize the upload request object into JSON
    String uploadRequestJson = jsonEncode({
      'productName': uploadRequest.productName,
      'description': uploadRequest.description,
      'wastage': uploadRequest.wastage,
      'weight': uploadRequest.weight,
      'karat': uploadRequest.karat,
      'categoryName': uploadRequest.categoryName,
      'categoryId': uploadRequest.categoryId,
      'subCategoryName': uploadRequest.subCategoryName,
      'subCategoryId': uploadRequest.subCategoryId,
      'tagNumber': uploadRequest.tagNumber,
      'length': uploadRequest.length,
      'size': uploadRequest.size,
      'wholesaler': uploadRequest.wholesaler,
      'wholesalerId': uploadRequest.wholesalerId,
      'occasion': uploadRequest.occasion,
      'soulmate': uploadRequest.soulmate,
      'gifting': uploadRequest.gifting,
      'gender': uploadRequest.gender,
      'productType': uploadRequest.productType,
    });

    // Step 9: Create the MultipartRequest for the form upload
    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
      })
      ..fields['uploadRequest'] = uploadRequestJson;

    // Step 10: Attach images to the request
    for (var image in _selectedImages) {
      var file = await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: MediaType('image', image.path.split('.').last),
      );
      request.files.add(file);
    }

    // Step 11: Send the request
    var response = await request.send();

    // Step 12: Handle the response
    if (response.statusCode == 200) {
      print("Product uploaded successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );
      setState(() {
        _selectedImages.clear();
        _productNameController.clear();
        _descriptionController.clear();
        _wastageController.clear();
        _weightController.clear();
        _selectedCategory = null;
        _selectedSubCategory = null;
        _selectedGender = null;
        _selectedKarat = '18K';
        _selectedSoulmate = null;
        _selectedOccasion = null;
        _selectedGifting = null;
      });
    } else {
      String responseBody = await response.stream.bytesToString();
      print("Failed to upload product. Response: $responseBody");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to upload product. Status code: ${response.statusCode}, Response: $responseBody')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building UI...");
    final dio = Dio();
    final categoryRepository = CategoryRepository(dio);
    final subCategoryRepository = SubCategoryRepository(dio);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AddProductBloc(
            categoryRepository: categoryRepository,
            subCategoryRepository: subCategoryRepository,
          )..loadCategories(layoutPosition: 1),
        ),
        BlocProvider(
          create: (_) => SubCategoryBloc(subCategoryRepository),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Add Product',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: kWhite),
          ),
          centerTitle: true,
          backgroundColor: kPrimary,
          elevation: 5,
        ),
        body: BlocBuilder<AddProductBloc, List<Category>>(
          builder: (context, categories) {
            if (categories.isEmpty) {
              print("Loading categories...");
              return const Center(child: CircularProgressIndicator());
            }
            print("Categories loaded: ${categories.length}");
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<Category>(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                        isExpanded: true,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.categoryName),
                          );
                        }).toList(),
                        onChanged: (selectedCategory) {
                          print(
                              "Category selected: ${selectedCategory?.categoryName}");
                          setState(() {
                            _selectedCategory = selectedCategory;
                          });

                          if (selectedCategory != null &&
                              ['Gold', 'Silver', 'Diamond']
                                  .contains(selectedCategory.categoryName)) {
                            // Default to "MALE" or "FEMALE" based on _selectedGender
                            final genderString = _selectedGender == 1
                                ? "MEN"
                                : _selectedGender == 2
                                    ? "WOMEN"
                                    : null; // Fallback to null if no gender selected
                            context.read<SubCategoryBloc>().loadSubCategories(
                                  categoryId: selectedCategory.categoryId,
                                  gender: genderString, // Pass gender as String
                                );
                          } else {
                            // For other categories, pass null gender
                            context.read<SubCategoryBloc>().loadSubCategories(
                                  categoryId: selectedCategory?.categoryId ?? 0,
                                  gender: null,
                                );
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Category',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    // Gender Radio Buttons (Only for Gold, Silver, and Diamond)
                    if (_selectedCategory != null &&
                        ['Gold', 'Silver', 'Diamond']
                            .contains(_selectedCategory!.categoryName))
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: RadioListTile<int>(
                                activeColor: kPrimary,
                                title: const Text('WOMEN'),
                                value: 1,
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  print("Gender selected: WOMEN");
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                  if (value != null) {
                                    context
                                        .read<SubCategoryBloc>()
                                        .loadSubCategories(
                                          categoryId:
                                              _selectedCategory!.categoryId,
                                          gender: "MEN", // Pass "MALE"
                                        );
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<int>(
                                activeColor: kPrimary,
                                title: const Text('WOMEN'),
                                value: 2,
                                groupValue: _selectedGender,
                                onChanged: (value) {
                                  print("Gender selected: WOMEN");
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                  if (value != null) {
                                    context
                                        .read<SubCategoryBloc>()
                                        .loadSubCategories(
                                          categoryId:
                                              _selectedCategory!.categoryId,
                                          gender: "WOMEN", // Pass "FEMALE"
                                        );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    BlocBuilder<SubCategoryBloc, SubCategoryState>(
                      builder: (context, state) {
                        if (state is SubCategoryLoading) {
                          print("Loading subcategories...");
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is SubCategoryLoaded) {
                          final subCategories = state.subcategories;
                          print(
                              "Subcategories loaded: ${subCategories.length}");
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: DropdownButtonFormField<SubCategory>(
                              dropdownColor: kPrimary,
                              style: TextStyle(color: kWhite, fontSize: 18),
                              isExpanded: true,
                              items: subCategories.map((subCategory) {
                                return DropdownMenuItem(
                                  value: subCategory,
                                  child: Text(subCategory.subCategoryName),
                                );
                              }).toList(),
                              onChanged: (selectedSubCategory) {
                                print(
                                    "Subcategory selected: ${selectedSubCategory?.subCategoryName}");
                                setState(() {
                                  _selectedSubCategory = selectedSubCategory;
                                });
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Select SubCategory',
                                  border: OutlineInputBorder()),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),

                    // Other input fields for product details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _productNameController,
                        decoration: const InputDecoration(
                            labelText: 'Product Name',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _wastageController,
                        decoration: const InputDecoration(
                            labelText: 'Wastage', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter wastage';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                            labelText: 'Weight(g)',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter weight';
                          }
                          return null;
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingGiftingOptions
                          ? const Center(child: CircularProgressIndicator())
                          : _giftingOptions.isEmpty
                              ? const Text('No gifting options available')
                              : DropdownButtonFormField<String>(
                                  dropdownColor: kPrimary,
                                  style: TextStyle(color: kWhite, fontSize: 18),
                                  isExpanded: true,
                                  value: _selectedGifting,
                                  decoration: const InputDecoration(
                                      labelText: 'Gifting',
                                      border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    print('Gifting selected: $value');
                                    setState(() {
                                      _selectedGifting = value;
                                    });
                                  },
                                  items: _giftingOptions
                                      .map(
                                          (gifting) => DropdownMenuItem<String>(
                                                value: gifting,
                                                child: Text(gifting),
                                              ))
                                      .toList(),
                                ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingSoulmateOptions
                          ? const Center(child: CircularProgressIndicator())
                          : _soulmateOptions.isEmpty
                              ? const Text('No soulmate options available')
                              : DropdownButtonFormField<String>(
                                  dropdownColor: kPrimary,
                                  style: TextStyle(color: kWhite, fontSize: 18),
                                  isExpanded: true,
                                  value: _selectedSoulmate,
                                  decoration: const InputDecoration(
                                      labelText: 'Soulmate',
                                      border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    print('Soulmate selected: $value');
                                    setState(() {
                                      _selectedSoulmate = value;
                                    });
                                  },
                                  items: _soulmateOptions
                                      .map((soulmate) =>
                                          DropdownMenuItem<String>(
                                            value: soulmate,
                                            child: Text(soulmate),
                                          ))
                                      .toList(),
                                ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingOccasionOptions
                          ? const Center(child: CircularProgressIndicator())
                          : _occasionOptions.isEmpty
                              ? const Text('No occasion options available')
                              : DropdownButtonFormField<String>(
                                  dropdownColor: kPrimary,
                                  style: TextStyle(color: kWhite, fontSize: 18),
                                  isExpanded: true,
                                  value: _selectedOccasion,
                                  decoration: const InputDecoration(
                                      labelText: 'Occasion',
                                      border: OutlineInputBorder()),
                                  onChanged: (value) {
                                    print('Occasion selected: $value');
                                    setState(() {
                                      _selectedOccasion = value;
                                    });
                                  },
                                  items: _occasionOptions
                                      .map((occasion) =>
                                          DropdownMenuItem<String>(
                                            value: occasion,
                                            child: Text(occasion),
                                          ))
                                      .toList(),
                                ),
                    ),

                    // Karat Dropdown
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DropdownButtonFormField<String>(
                        dropdownColor: kPrimary,
                        style: TextStyle(color: kWhite, fontSize: 18),
                        isExpanded: true,
                        value: _selectedKarat,
                        onChanged: (value) {
                          print("Karat selected: $value");
                          setState(() {
                            _selectedKarat = value;
                          });
                        },
                        items: ['18K', '22K', '24K']
                            .map((karat) => DropdownMenuItem<String>(
                                  value: karat,
                                  child: Text(karat),
                                ))
                            .toList(),
                        decoration: const InputDecoration(
                            labelText: 'Select Karat',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    // Image Picker Buttons
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary),
                            onPressed: () => _pickImages(ImageSource.gallery),
                            child: const Text(
                              'Pick Images',
                              style: TextStyle(color: kWhite),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary),
                            onPressed: _captureImage,
                            child: const Text(
                              'Capture Image',
                              style: TextStyle(color: kWhite),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Display Selected Images
                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          children: _selectedImages.map((image) {
                            return Stack(
                              children: [
                                Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () => _removeImage(
                                        _selectedImages.indexOf(image)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            fixedSize: Size(450, 55)),
                        onPressed: _submitProduct,
                        child: const Text(
                          'Submit Product',
                          style: TextStyle(color: kWhite, fontSize: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
