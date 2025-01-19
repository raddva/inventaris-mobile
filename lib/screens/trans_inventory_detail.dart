import 'package:flutter/material.dart';
import 'package:inventaris/data_modules/category_model.dart';
import 'package:inventaris/data_modules/inventory_model.dart';
import 'package:inventaris/data_modules/pj_model.dart';
import 'package:inventaris/data_modules/product_model.dart';
import 'package:inventaris/data_modules/status_model.dart';
import 'package:inventaris/modules/api_services.dart';

class InventoryForm extends StatefulWidget {
  final Inventory? inventory;
  final VoidCallback? onFormSubmit;

  const InventoryForm({super.key, this.inventory, this.onFormSubmit});

  @override
  State<InventoryForm> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<InventoryForm> {
  final CategoryController _categoryController = CategoryController();
  final PJController _pjController = PJController();
  final ProductController _productController = ProductController();
  final StatusController _statusController = StatusController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> pjs = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> statuses = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  String? selectedCategoryId;

  bool _isSubmitting = false;
  final List<Map<String, dynamic>> _details = [];
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();

    if (widget.inventory != null) {
      _codeController.text = widget.inventory!.transcode;
      _dateController.text = widget.inventory!.transdate;
      _remarkController.text = widget.inventory!.remark;
      selectedCategoryId = widget.inventory!.categoryId.toString();
    }

    _fetchDropdowns();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoadingDetails = true;
    });
    try {
      List<Map<String, dynamic>>? fetchedDetails = [];

      if (widget.inventory != null) {
        fetchedDetails =
            await ApiService().fetchInventoryDetails(widget.inventory!.id);
        if (fetchedDetails != null) {
          _details.addAll(fetchedDetails.map((e) {
            if (e['pjid'] == "0") {
              e['pjid'] = null;
            }
            return e;
          }).toList());
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _fetchDropdowns() async {
    setState(() {
      _isLoadingDetails = true;
    });
    try {
      final fetchedCategories = await _categoryController.fetchCategories();
      final fetchedProducts = await _productController.fetchProducts();
      final fetchedPJs = await _pjController.fetchPJs();
      final fetchedStatuses = await _statusController.fetchStatuses();

      setState(() {
        categories = fetchedCategories ?? [];
        products = fetchedProducts ?? [];
        pjs = fetchedPJs ?? [];
        statuses = fetchedStatuses ?? [];

        if (widget.inventory != null) {
          selectedCategoryId = widget.inventory!.categoryId.toString();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  void _addDetail() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController qtyController = TextEditingController();
        TextEditingController remarkController = TextEditingController();

        String? tempSelectedProductId;
        String? tempSelectedStatusId;
        String? tempSelectedPJId;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Detail'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: tempSelectedProductId,
                      onChanged: (value) {
                        setState(() {
                          tempSelectedProductId = value;
                        });
                      },
                      items: products.map((product) {
                        return DropdownMenuItem<String>(
                          value: product['id'].toString(),
                          child: Text(product['nama'] ?? 'Unknown'),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: "Product"),
                    ),
                    DropdownButtonFormField<String>(
                      value: tempSelectedStatusId,
                      onChanged: (value) {
                        setState(() {
                          tempSelectedStatusId = value;
                        });
                      },
                      items: statuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status['id'].toString(),
                          child: Text(status['nama'] ?? 'Unknown'),
                        );
                      }).toList(),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                    DropdownButtonFormField<String>(
                      value: tempSelectedPJId,
                      onChanged: (value) {
                        setState(() {
                          tempSelectedPJId = value;
                        });
                      },
                      items: pjs.map((pj) {
                        return DropdownMenuItem<String>(
                          value: pj['id'].toString(),
                          child: Text(pj['nama'] ?? 'Unknown'),
                        );
                      }).toList(),
                      decoration:
                          const InputDecoration(labelText: 'Person in Charge'),
                    ),
                    TextFormField(
                      controller: qtyController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: remarkController,
                      decoration: const InputDecoration(labelText: 'Remark'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (tempSelectedProductId != null &&
                        tempSelectedStatusId != null &&
                        qtyController.text.isNotEmpty) {
                      final newDetail = {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'productid': int.parse(tempSelectedProductId!),
                        'statusid': int.parse(tempSelectedStatusId!),
                        'pjid': tempSelectedPJId != null
                            ? int.tryParse(tempSelectedPJId!)
                            : 0,
                        'qty': int.tryParse(qtyController.text) ?? 0,
                        'remark': remarkController.text,
                        'productName': products.firstWhere(
                          (p) => p['id'].toString() == tempSelectedProductId,
                          orElse: () => {'nama': 'Unknown'},
                        )['nama'],
                      };
                      print(newDetail);
                      _addOrUpdateDetail(newDetail);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editDetail(int detailId) async {
    try {
      final detail = _details.firstWhere((d) => d['id'] == detailId);
      TextEditingController qtyController =
          TextEditingController(text: detail['qty'].toString());
      TextEditingController remarkController =
          TextEditingController(text: detail['remark']);
      String? tempSelectedProductId = detail['productid'].toString();
      String? tempSelectedStatusId = detail['statusid'].toString();
      String? tempSelectedPJId =
          detail['pjid'] != 0 ? (detail['pjid']?.toString()) : null;

      await showDialog(
          context: (context),
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                title: Text('Edit Detail'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: tempSelectedProductId,
                        onChanged: (value) {
                          setState(() {
                            tempSelectedProductId = value;
                          });
                        },
                        items: products.map((product) {
                          return DropdownMenuItem<String>(
                            value: product['id'].toString(),
                            child: Text(product['nama'] ?? 'Unknown'),
                          );
                        }).toList(),
                        decoration: const InputDecoration(labelText: "Product"),
                      ),
                      DropdownButtonFormField<String>(
                        value: tempSelectedStatusId,
                        onChanged: (value) {
                          setState(() {
                            tempSelectedStatusId = value;
                          });
                        },
                        items: statuses.map((status) {
                          return DropdownMenuItem<String>(
                            value: status['id'].toString(),
                            child: Text(status['nama'] ?? 'Unknown'),
                          );
                        }).toList(),
                        decoration: const InputDecoration(labelText: 'Status'),
                      ),
                      DropdownButtonFormField<String>(
                        value: tempSelectedPJId,
                        onChanged: (value) {
                          setState(() {
                            tempSelectedPJId = value;
                          });
                        },
                        items: pjs.map((pj) {
                          return DropdownMenuItem<String>(
                            value: pj['id'].toString(),
                            child: Text(pj['nama'] ?? 'Unknown'),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                            labelText: 'Person in Charge'),
                      ),
                      TextFormField(
                        controller: qtyController,
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                      ),
                      TextFormField(
                        controller: remarkController,
                        decoration: const InputDecoration(labelText: 'Remark'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (tempSelectedProductId != null &&
                          tempSelectedStatusId != null &&
                          qtyController.text.isNotEmpty) {
                        final updatedDetail = {
                          ...detail,
                          'productid': int.parse(tempSelectedProductId!),
                          'statusid': int.parse(tempSelectedStatusId!),
                          'pjid': tempSelectedPJId != null
                              ? int.parse(tempSelectedPJId!)
                              : 0,
                          'qty': int.tryParse(qtyController.text) ?? 0,
                          'remark': remarkController.text,
                        };
                        _addOrUpdateDetail(updatedDetail);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all fields.')),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            });
          });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _addOrUpdateDetail(Map<String, dynamic> newDetail) {
    setState(() {
      final detailIndex =
          _details.indexWhere((d) => d['id'] == newDetail['id']);
      if (detailIndex != -1) {
        _details[detailIndex] = newDetail;
      } else {
        _details.add(newDetail);
      }
    });
  }

  void _removeDetail(int index) async {
    final detail = _details[index];
    if (detail.containsKey('id')) {
      try {
        await ApiService().removeInventoryDetail(detail['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Detail deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting detail: $e')),
        );
        return;
      }
    }
    setState(() {
      _details.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one detail.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.inventory == null) {
        final headerId = await ApiService().addInventory(
          _codeController.text,
          _dateController.text,
          _remarkController.text,
          int.parse(selectedCategoryId!),
        );

        for (var detail in _details) {
          await ApiService().addInventoryDetail(
            headerId,
            detail['productid'],
            detail['statusid'],
            detail['remark'],
            detail['pjid'],
            detail['qty'],
          );
        }
      } else {
        await ApiService().editInventory(
          widget.inventory!.id,
          _codeController.text,
          _dateController.text,
          _remarkController.text,
          int.parse(selectedCategoryId!),
        );

        for (var detail in _details) {
          if (detail.containsKey('id')) {
            await ApiService().editInventoryDetail(
              detail['id'],
              widget.inventory!.id,
              int.parse(detail['productid']),
              int.parse(detail['statusid']),
              detail['remark'],
              int.parse(detail['pjid'] ?? 0),
              detail['qty'],
            );
          } else {
            await ApiService().addInventoryDetail(
              widget.inventory!.id,
              (detail['productid']),
              detail['statusid'],
              detail['remark'],
              detail['pjid'] ?? 0,
              detail['qty'],
            );
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory saved successfully!')),
      );

      widget.onFormSubmit?.call();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.inventory == null ? 'Add Inventory' : 'Edit Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration:
                      const InputDecoration(labelText: 'Transaction Code'),
                ),
                TextFormField(
                  controller: _dateController,
                  decoration:
                      const InputDecoration(labelText: 'Transaction Date'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      _dateController.text =
                          "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                    }
                  },
                ),
                TextFormField(
                  controller: _remarkController,
                  decoration: const InputDecoration(labelText: 'Remark'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  onChanged: (value) =>
                      setState(() => selectedCategoryId = value),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id'].toString(),
                      child: Text("${category['nama'] ?? 'Unknown'}"),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Details',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () => _addDetail(),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_isLoadingDetails)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (_details.isEmpty)
                  const Text('No details added yet.')
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _details.length,
                    itemBuilder: (context, index) {
                      final detail = _details[index];
                      return ListTile(
                        title: Text(
                            detail['productName'] ?? detail['product']['nama']),
                        subtitle: Text('Qty: ${detail['qty']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editDetail(detail['id'] ?? 0),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeDetail(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
