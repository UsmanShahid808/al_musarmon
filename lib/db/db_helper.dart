import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import '../models/sale_item_model.dart';
import '../models/order_model.dart';
import '../models/supplier_model.dart';
import '../models/supplier_transaction_model.dart';
import '../models/worker_model.dart';
import '../models/worker_transaction_model.dart';

class DBHelper {
  static Database? _db;

  static Database? get currentDb => _db;

  static void resetDbInstance() {
    _db = null;
  }

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<void> closeAndReset() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'khata_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE customers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          address TEXT,
          balance REAL DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )''');

        await db.execute('''CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          date TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (customer_id) REFERENCES customers(id)
        )''');

        await db.execute('''CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          purchase_price REAL,
          sale_price REAL,
          quantity REAL DEFAULT 0,
          avg_piece_length REAL DEFAULT 3,
          thaan_length REAL DEFAULT 23,
          thaan_cost REAL DEFAULT 0,
          low_stock_alert REAL DEFAULT 5,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )''');

        await db.execute('''CREATE TABLE sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER,
          total_amount REAL NOT NULL,
          paid_amount REAL DEFAULT 0,
          date TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (customer_id) REFERENCES customers(id)
        )''');

        await db.execute('''CREATE TABLE sale_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          quantity REAL NOT NULL,
          price REAL NOT NULL,
          FOREIGN KEY (sale_id) REFERENCES sales(id),
          FOREIGN KEY (product_id) REFERENCES products(id)
        )''');

        await db.execute('''CREATE TABLE orders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER NOT NULL,
          item_description TEXT NOT NULL,
          total_amount REAL NOT NULL,
          advance_paid REAL DEFAULT 0,
          status TEXT DEFAULT 'pending',
          order_date TEXT DEFAULT CURRENT_TIMESTAMP,
          ready_date TEXT,
          FOREIGN KEY (customer_id) REFERENCES customers(id)
        )''');

        await db.execute('''CREATE TABLE suppliers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          address TEXT,
          balance REAL DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )''');

        await db.execute('''CREATE TABLE supplier_transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          supplier_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          date TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
        )''');

        await db.execute('''CREATE TABLE workers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          balance REAL DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )''');

        await db.execute('''CREATE TABLE worker_transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          worker_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          note TEXT,
          date TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (worker_id) REFERENCES workers(id)
        )''');

        // Seed default workers
        await db.insert('workers', {'name': 'Shahzad', 'phone': '', 'balance': 0});
        await db.insert('workers', {'name': 'Amjad', 'phone': '', 'balance': 0});
        await db.insert('workers', {'name': 'Manan', 'phone': '', 'balance': 0});
        await db.insert('workers', {'name': 'Shakeel', 'phone': '', 'balance': 0});
        await db.insert('workers', {'name': 'Vicky', 'phone': '', 'balance': 0});

        // Seed default suppliers
        await db.insert('suppliers', {'name': 'شركة ابراهيم سليمان العجلان', 'phone': '', 'address': '', 'balance': 0});
        await db.insert('suppliers', {'name': 'الجديعي', 'phone': '', 'address': '', 'balance': 0});
        await db.insert('suppliers', {'name': 'المحبه', 'phone': '', 'address': '', 'balance': 0});
        await db.insert('suppliers', {'name': 'العيسائي', 'phone': '', 'address': '', 'balance': 0});

        // Seed default products (price/stock 0, edit later)
        await db.insert('products', {
          'name': 'Aurafeel', 'purchase_price': 0, 'sale_price': 0, 'quantity': 0,
          'avg_piece_length': 3, 'thaan_length': 23, 'thaan_cost': 0, 'low_stock_alert': 5
        });
        await db.insert('products', {
          'name': 'Vitoria', 'purchase_price': 0, 'sale_price': 0, 'quantity': 0,
          'avg_piece_length': 3, 'thaan_length': 23, 'thaan_cost': 0, 'low_stock_alert': 5
        });
        await db.insert('products', {
          'name': 'Bellanty', 'purchase_price': 0, 'sale_price': 0, 'quantity': 0,
          'avg_piece_length': 3, 'thaan_length': 23, 'thaan_cost': 0, 'low_stock_alert': 5
        });
        await db.insert('products', {
          'name': 'Sameeramees', 'purchase_price': 0, 'sale_price': 0, 'quantity': 0,
          'avg_piece_length': 3, 'thaan_length': 23, 'thaan_cost': 0, 'low_stock_alert': 5
        });
        await db.insert('products', {
          'name': 'Zain', 'purchase_price': 0, 'sale_price': 0, 'quantity': 0,
          'avg_piece_length': 3, 'thaan_length': 23, 'thaan_cost': 0, 'low_stock_alert': 5
        });
        await db.insert('products', {
          'name': 'Gently', 'purchase_price': 0, 'sale_price': 0, 'quantity': 0,
          'avg_piece_length': 3, 'thaan_length': 23, 'thaan_cost': 0, 'low_stock_alert': 5
        });
      },
    );
  }

  // ================= CUSTOMER FUNCTIONS =================

  static Future<int> addCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  static Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Customer.fromMap(maps[i]);
    });
  }

  static Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateBalance(int id, double newBalance) async {
    final db = await database;
    return await db.update(
      'customers',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  // ================= TRANSACTION FUNCTIONS =================

  static Future<int> addTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  static Future<List<TransactionModel>> getTransactionsByCustomer(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return TransactionModel.fromMap(maps[i]);
    });
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ================= PRODUCT FUNCTIONS =================

  static Future<int> addProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  static Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  static Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateProductQuantity(int id, double newQuantity) async {
    final db = await database;
    return await db.update(
      'products',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= SALE FUNCTIONS =================

  static Future<int> addSale(Sale sale) async {
    final db = await database;
    return await db.insert('sales', sale.toMap());
  }

  static Future<int> addSaleItem(SaleItem item) async {
    final db = await database;
    return await db.insert('sale_items', item.toMap());
  }

  static Future<List<Sale>> getAllSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sales', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return Sale.fromMap(maps[i]);
    });
  }

  static Future<List<Map<String, dynamic>>> getSaleItemsWithProductName(int saleId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT sale_items.*, products.name as product_name
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      WHERE sale_items.sale_id = ?
    ''', [saleId]);
  }

  static Future<double> getTodayTotalSale() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total FROM sales
      WHERE date(date) = date('now')
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // ================= DASHBOARD/REPORTS FUNCTIONS =================

  static Future<double> getTotalOutstanding() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(balance) as total FROM customers
      WHERE balance > 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  static Future<List<Product>> getLowStockProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM products WHERE quantity <= low_stock_alert
    ''');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // ================= ORDER FUNCTIONS =================

  static Future<int> addOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  static Future<List<OrderModel>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT orders.*, customers.name as customer_name, customers.phone as customer_phone
      FROM orders
      JOIN customers ON orders.customer_id = customers.id
      ORDER BY 
        CASE status
          WHEN 'ready' THEN 1
          WHEN 'pending' THEN 2
          WHEN 'delivered' THEN 3
        END,
        orders.order_date DESC
    ''');
    return maps.map((m) {
      OrderModel o = OrderModel.fromMap(m);
      o.customerName = m['customer_name'] ?? '';
      return o;
    }).toList();
  }

  static Future<int> updateOrderStatus(int id, String status, {String? readyDate}) async {
    final db = await database;
    Map<String, dynamic> data = {'status': status};
    if (readyDate != null) data['ready_date'] = readyDate;
    return await db.update('orders', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateOrderPayment(int id, double advancePaid) async {
    final db = await database;
    return await db.update('orders', {'advance_paid': advancePaid}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> addOrderAsSale(int customerId, double amount, String description) async {
    final db = await database;
    return await db.insert('sales', {
      'customer_id': customerId,
      'total_amount': amount,
      'paid_amount': amount,
    });
  }

  static Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Customer?> getCustomerById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }

  // ================= SUPPLIER FUNCTIONS =================

  static Future<int> addSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('suppliers', supplier.toMap());
  }

  static Future<List<Supplier>> getAllSuppliers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('suppliers', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Supplier.fromMap(maps[i]);
    });
  }

  static Future<int> updateSupplier(Supplier supplier) async {
    final db = await database;
    return await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  static Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateSupplierBalance(int id, double newBalance) async {
    final db = await database;
    return await db.update(
      'suppliers',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> addSupplierTransaction(SupplierTransaction transaction) async {
    final db = await database;
    return await db.insert('supplier_transactions', transaction.toMap());
  }

  static Future<List<SupplierTransaction>> getSupplierTransactions(int supplierId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'supplier_transactions',
      where: 'supplier_id = ?',
      whereArgs: [supplierId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return SupplierTransaction.fromMap(maps[i]);
    });
  }

  static Future<int> deleteSupplierTransaction(int id) async {
    final db = await database;
    return await db.delete('supplier_transactions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<double> getTotalPayable() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(balance) as total FROM suppliers
      WHERE balance > 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // ================= PROFIT/LOSS FUNCTIONS =================

  static Future<double> getTotalRevenue() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total FROM sales
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  static Future<double> getTotalCostOfGoodsSold() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(sale_items.quantity * products.purchase_price) as total
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getProfitByProduct() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        products.name as product_name,
        SUM(sale_items.quantity) as total_sold,
        SUM(sale_items.quantity * sale_items.price) as revenue,
        SUM(sale_items.quantity * products.purchase_price) as cost
      FROM sale_items
      JOIN products ON sale_items.product_id = products.id
      GROUP BY products.id
      ORDER BY revenue DESC
    ''');
  }

  static Future<int> getTotalOrdersCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sales');
    return (result.first['count'] as int?) ?? 0;
  }

  static Future<Map<String, dynamic>> getSalesInDateRange(String startDate, String endDate) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total, COUNT(*) as count
      FROM sales
      WHERE date(date) BETWEEN date(?) AND date(?)
    ''', [startDate, endDate]);

    return {
      'total': (result.first['total'] as num?)?.toDouble() ?? 0,
      'count': (result.first['count'] as int?) ?? 0,
    };
  }

  // ================= WORKER FUNCTIONS =================

  static Future<int> addWorker(Worker worker) async {
    final db = await database;
    return await db.insert('workers', worker.toMap());
    
  }

  static Future<List<Worker>> getAllWorkers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('workers', orderBy: 'name ASC');
    return List.generate(maps.length, (i) {
      return Worker.fromMap(maps[i]);
    });
  }

  static Future<int> updateWorker(Worker worker) async {
    final db = await database;
    return await db.update(
      'workers',
      worker.toMap(),
      where: 'id = ?',
      whereArgs: [worker.id],
    );
  }

  static Future<int> deleteWorker(int id) async {
    final db = await database;
    return await db.delete('workers', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> updateWorkerBalance(int id, double newBalance) async {
    final db = await database;
    return await db.update(
      'workers',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> addWorkerTransaction(WorkerTransaction transaction) async {
    final db = await database;
    return await db.insert('worker_transactions', transaction.toMap());
  }

  static Future<List<WorkerTransaction>> getWorkerTransactions(int workerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'worker_transactions',
      where: 'worker_id = ?',
      whereArgs: [workerId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) {
      return WorkerTransaction.fromMap(maps[i]);
    });
  }

  static Future<int> deleteWorkerTransaction(int id) async {
    final db = await database;
    return await db.delete('worker_transactions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<double> getTotalWorkerPayable() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(balance) as total FROM workers
      WHERE balance > 0
    ''');
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }
  static Future<Map<String, double>> getWorkerStats(int workerId) async {
    final db = await database;
    final work = await db.rawQuery(
        "SELECT SUM(amount) as total FROM worker_transactions WHERE worker_id = ? AND type = 'work'", [workerId]);
    final paid = await db.rawQuery(
        "SELECT SUM(amount) as total FROM worker_transactions WHERE worker_id = ? AND type = 'payment'", [workerId]);
    return {
      'totalWork': (work.first['total'] as num?)?.toDouble() ?? 0,
      'totalPaid': (paid.first['total'] as num?)?.toDouble() ?? 0,
    };
  }

  static Future<Map<String, double>> getSupplierStats(int supplierId) async {
    final db = await database;
    final received = await db.rawQuery(
        "SELECT SUM(amount) as total FROM supplier_transactions WHERE supplier_id = ? AND type = 'purchase'", [supplierId]);
    final paid = await db.rawQuery(
        "SELECT SUM(amount) as total FROM supplier_transactions WHERE supplier_id = ? AND type = 'payment'", [supplierId]);
    return {
      'totalReceived': (received.first['total'] as num?)?.toDouble() ?? 0,
      'totalPaid': (paid.first['total'] as num?)?.toDouble() ?? 0,
    };
  }
}