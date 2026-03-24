import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestion_inventario_zaitec/FirebaseManager.dart'; // Ajusta según tu proyecto

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Pruebas de Integración: Filtros de Citas', () {
    late FirebaseManager manager;

    setUpAll(() async {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      manager = FirebaseManager();
    });

    testWidgets('Filtro por Servicio: Solo devuelve el servicio específico', (tester) async {
      // 1. PRIMERO: Vamos a ver TODO lo que hay en la base de datos para depurar
      print('\n--- DEBUG: EXPLORANDO COLECCIÓN "Citas" ---');
      final totalCitas = await FirebaseFirestore.instance.collection('Citas').get();
      
      if (totalCitas.docs.isEmpty) {
        print('ALERTA: La colección "Citas" está VACÍA en Firebase.');
      } else {
        print('Total de documentos en DB: ${totalCitas.docs.length}');
        for (var doc in totalCitas.docs) {
          print('Doc ID: ${doc.id} | Datos: ${doc.data()}');
        }
      }

      // 2. AHORA: Probamos el filtro específico
      final servicioABuscar = 'barba'; // CAMBIA ESTO por un valor que hayas visto arriba
      print('\n--- EJECUTANDO FILTRO: servicio = "$servicioABuscar" ---');
      
      final snapshot = await manager.obtenerCitasPeluquero(servicio: servicioABuscar).first;

      print('Resultados del filtro: ${snapshot.docs.length}');

      // 3. VALIDACIÓN CON PRINT
      if (snapshot.docs.isEmpty) {
        fail('El filtro no devolvió nada para "$servicioABuscar". Revisa si el campo en Firestore se llama "servicio" (en minúsculas) y si el valor coincide exactamente.');
      }

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Validando doc ${doc.id}: ${data['Servicio']}');
        
        expect(data['Servicio'], equals(servicioABuscar), 
          reason: 'El documento ${doc.id} no coincide con el filtro esperado.');
      }
    });

    testWidgets('Filtro por Usuario: Ver resultados posibles', (tester) async {
      final nombreABuscar = 'Ivan Test Real'; 
      print('\n--- EJECUTANDO FILTRO: usuario = "$nombreABuscar" ---');

      final snapshot = await manager.obtenerCitasPeluquero(usuario: nombreABuscar).first;

      print('Citas encontradas para "$nombreABuscar": ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        print('Doc encontrado: ${data['Usuario']}');
        expect(data['Usuario'], equals(nombreABuscar));
      }
    });
  });
}