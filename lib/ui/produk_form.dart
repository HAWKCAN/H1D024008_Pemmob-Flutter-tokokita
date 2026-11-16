import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/produk.dart';
import 'api.dart';

class ProdukForm extends StatefulWidget {
  final Produk? produk;
  const ProdukForm({super.key, this.produk});

  @override
  State<ProdukForm> createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  bool get _isUpdate => widget.produk != null;

  @override
  void initState() {
    super.initState();
    if (_isUpdate) {
      _kodeController.text = widget.produk!.kodeProduk ?? '';
      _namaController.text = widget.produk!.namaProduk ?? '';
      _hargaController.text = widget.produk!.hargaProduk?.toString() ?? '';
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = jsonEncode({
      'kode_produk': _kodeController.text,
      'nama_produk': _namaController.text,
      'harga': _hargaController.text,
    });
    final url = _isUpdate
        ? '$baseUrl/produk/${widget.produk!.id}'
        : '$baseUrl/produk';

    try {
      final response = _isUpdate
          ? await http
              .put(Uri.parse(url),
                  headers: {'Content-Type': 'application/json'}, body: data)
              .timeout(const Duration(seconds: 10))
          : await http
              .post(Uri.parse(url),
                  headers: {'Content-Type': 'application/json'}, body: data)
              .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);
      if (!mounted) return;
      if (body['status'] == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['data'].toString())),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUpdate ? 'UBAH PRODUK' : 'TAMBAH PRODUK'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _kodeController,
                decoration: const InputDecoration(labelText: 'Kode Produk'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Kode Produk harus diisi' : null,
              ),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Nama Produk harus diisi' : null,
              ),
              TextFormField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Harga harus diisi' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isUpdate ? 'UBAH' : 'SIMPAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
