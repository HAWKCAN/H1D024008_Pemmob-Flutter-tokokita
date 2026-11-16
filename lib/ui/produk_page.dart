import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/produk.dart';
import 'api.dart';
import 'login_page.dart';
import 'produk_detail.dart';
import 'produk_form.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  List<Produk> _produkList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  Future<void> _fetchProduk() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/produk'))
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body);
      if (!mounted) return;
      if (body['status'] == true) {
        final List data = body['data'];
        setState(() {
          _produkList = data.map((e) => Produk.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat produk: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _tambahProduk() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProdukForm()),
    );
    if (result == true) _fetchProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahProduk,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout),
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProduk,
              child: ListView.builder(
                itemCount: _produkList.length,
                itemBuilder: (context, index) {
                  final produk = _produkList[index];
                  return ItemProduk(
                    produk: produk,
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProdukDetail(produk: produk),
                        ),
                      );
                      if (changed == true) _fetchProduk();
                    },
                  );
                },
              ),
            ),
    );
  }
}

class ItemProduk extends StatelessWidget {
  final Produk produk;
  final VoidCallback onTap;

  const ItemProduk({super.key, required this.produk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: ListTile(
          title: Text(produk.namaProduk ?? '-'),
          subtitle: Text('Rp ${produk.hargaProduk ?? 0}'),
        ),
      ),
    );
  }
}
