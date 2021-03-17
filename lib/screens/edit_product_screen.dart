import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/widgets/loading.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController(text: "");
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0.0,
  );
  var _initialValues = {
    'title': '',
    'description': '',
    'imageUrl': '',
    'price': '',
  };
  var _isLoading = false;
  var _isInit = true;
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initialValues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'imageUrl': '',
          'price': _editProduct.price.toString(),
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') ||
              !_imageUrlController.text.startsWith('https')) &&
          (!_imageUrlController.text.endsWith('.png') ||
              !_imageUrlController.text.endsWith('.jpg') ||
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
        // ignore: dead_code
        setState(() {});
      }
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _formKey.currentState.validate();
    if (!_isValid) return;
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false).updateProdcut(
        id: _editProduct.id,
        product: _editProduct,
      );
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProdcut(_editProduct);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went worng'),
            actions: [
              FlatButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Okay"),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit product"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Loading()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initialValues['title'],
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) =>
                          value.isEmpty ? "please provide a value" : null,
                      onSaved: (value) {
                        _editProduct = Product(
                          title: value,
                          description: _editProduct.description,
                          id: _editProduct.id,
                          imageUrl: _editProduct.imageUrl,
                          price: _editProduct.price,
                        );
                      },
                    ),
                    TextFormField(
                      focusNode: _priceFocusNode,
                      initialValue: _initialValues['price'].toString(),
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) => double.tryParse(value) == null ||
                              double.tryParse(value) <= 0 ||
                              value.isEmpty
                          ? "please  a valid price "
                          : null,
                      onSaved: (value) {
                        _editProduct = Product(
                          title: _editProduct.title,
                          description: _editProduct.description,
                          id: _editProduct.id,
                          imageUrl: _editProduct.imageUrl,
                          price: double.parse(value),
                        );
                      },
                    ),
                    TextFormField(
                      focusNode: _descriptionFocusNode,
                      initialValue: _initialValues['description'].toString(),
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      validator: (value) =>
                          value.isEmpty ? "please provide a value" : null,
                      onSaved: (value) {
                        _editProduct = Product(
                          title: _editProduct.title,
                          description: value,
                          id: _editProduct.id,
                          imageUrl: _editProduct.imageUrl,
                          price: _editProduct.price,
                        );
                      },
                    ),
                    Row(
                      children: [
                        Container(
                          width: 100.0,
                          height: 100.0,
                          margin: EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Center(child: Text("Enter a url"))
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: _imageUrlFocusNode,
                            decoration: InputDecoration(
                              labelText: 'Image url',
                            ),
                            controller: _imageUrlController,
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "please enter  url ";
                              } else if (!_imageUrlController.text
                                      .startsWith('http') ||
                                  !_imageUrlController.text
                                      .startsWith('https')) {
                                return "Please enter a valid url";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _editProduct = Product(
                                title: _editProduct.title,
                                description: _editProduct.description,
                                id: _editProduct.id,
                                imageUrl: value,
                                price: _editProduct.price,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
