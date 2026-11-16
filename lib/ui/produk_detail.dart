import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/produk.dart';
import 'api.dart';
import 'produk_form.dart';

class ProdukDetail extends StatelessWidget {
  final Produk produk;
  const ProdukDetail({super.key, required this.produk});

  Future<void> _hapus(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Yakin ingin menghapus data ini?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
    if (yakin != true) return;

    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/produk/${produk.id}'))
          .timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body);
      if (!context.mounted) return;
      if (body['status'] == true) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['data'].toString())),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Kode : ${produk.kodeProduk ?? '-'}',
                style: const TextStyle(fontSize: 20)),
            Text('Nama : ${produk.namaProduk ?? '-'}',
                style: const TextStyle(fontSize: 18)),
            Text('Harga : Rp. ${produk.hargaProduk ?? 0}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProdukForm(produk: produk)),
                    );
                    if (changed == true && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('EDIT'),
                ),
                OutlinedButton(
                  onPressed: () => _hapus(context),
                  child: const Text('DELETE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
