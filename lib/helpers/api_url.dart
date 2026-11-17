class ApiUrl {
  static const String baseUrl = 'http://10.47.116.12/ci4-api/public';

  static const String registrasi = '$baseUrl/registrasi';
  static const String login = '$baseUrl/login';

  // Karena produk menggunakan group('produk', ...) di CodeIgniter:
  static const String listProduk = '$baseUrl/produk';
  static const String createProduk = '$baseUrl/produk';

  static String updateProduk(int id) {
    return '$baseUrl/produk/$id';
  }

  static String showProduk(int id) {
    return '$baseUrl/produk/$id';
  }

  static String deleteProduk(int id) {
    return '$baseUrl/produk/$id';
  }
}