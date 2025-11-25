import 'package:flutter/material.dart';

void main() {
  runApp(const PetaniMajuApp());
}

class PetaniMajuApp extends StatelessWidget {
  const PetaniMajuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan tema hijau yang konsisten
    final Color primaryGreen =
        const Color(0xFF388E3C); // Warna hijau lebih tua dari desain
    final Color lightGreen = const Color(0xFF4CAF50); // Warna hijau cerah
    final Color darkGreen = const Color(0xFF2E7D32); // Warna hijau sangat gelap

    return MaterialApp(
      title: 'PetaniMaju App',
      theme: ThemeData(
          // Menggunakan primary color yang lebih dekat ke desain
          primaryColor: primaryGreen,
          hintColor: lightGreen, // Untuk warna border fokus input
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme:
                IconThemeData(color: Colors.white), // Panah kembali putih
            titleTextStyle: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: darkGreen, // Tombol login/register
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white
                .withOpacity(0.8), // Latar belakang input sedikit transparan
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none, // Menghilangkan border default
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Colors.grey.shade300), // Border abu-abu tipis
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: lightGreen, width: 2), // Border hijau saat fokus
            ),
            labelStyle: TextStyle(color: primaryGreen),
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIconColor: primaryGreen,
            suffixIconColor: primaryGreen,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: lightGreen, // Teks button hijau
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return lightGreen; // Warna centang hijau
              }
              return Colors.grey.shade400; // Warna saat tidak terpilih
            }),
            checkColor: MaterialStateProperty.all(Colors.white),
          )),
      home: const SplashScreen(), // Mulai dari splash screen
      // Mendefinisikan rute agar navigasi lebih rapi
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}
