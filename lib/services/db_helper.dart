import 'dart:async';
import 'dart:io' as io;
import 'package:Dietryz/services/food.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
 
class DBHelper 
{
  static Database _db;

  // Columns

  static const String ID             = 'id';
  static const String FOOD_NAME      = 'food_name';
  static const String FOOD_GROUP     = 'food_group';
  static const String DATE_CONSUMED  = 'date_consumed';
  static const String MEAL_TYPE      = 'meal_type';
  static const String NOTES          = 'notes';
  static const String REPORTER_NAME  = 'reporter_name';

  // Table 
  static const String TABLE   = 'Foods';

  // Database
  static const String DB_NAME = 'local.db';
 
  Future<Database> get db async 
  {
    if (_db != null) 
    {
      return _db;
    }
    _db = await initDb();
    return _db;
  }
 
  initDb() async 
  {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, DB_NAME);

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);

    return db;
  }
 
  _onCreate(Database db, int version) async 
  {
    await db.execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $FOOD_NAME TEXT, $FOOD_GROUP TEXT,$DATE_CONSUMED TEXT,$MEAL_TYPE TEXT,$NOTES TEXT,$REPORTER_NAME TEXT)");
  }
 
  Future<List<Food>> getAllFoods() async 
  {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE, columns: [ID, FOOD_NAME]);

    List<Food> foods = [];

    if (maps.length > 0) 
    {
      for (int i = 0; i < maps.length; i++) 
      {
        foods.add(Food.fromMap(maps[i]));
      }
    }

    return foods;
  }

  Future<int> findIfFoodExists(String foodName) async 
  {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE, columns: [ID,FOOD_NAME,FOOD_GROUP, MEAL_TYPE, DATE_CONSUMED, NOTES, REPORTER_NAME], where: '$FOOD_NAME = ?', whereArgs: [foodName] );

    if (maps.length > 0) 
    {
      return maps.length;
    }
    else
    {
      return -1;
    }
  }

  Future<Food> addFood(Food food) async 
  {
    var dbClient = await db;

    food.id = await dbClient.insert(TABLE, food.toMap());

    return food;
  }

  Future<int> updateFood(Food food, String foodId) async 
  {
    var dbClient = await db;

    return await dbClient.update(TABLE, food.toMap(), where: '$ID = ?', whereArgs: [foodId]);
  }
 
  Future<int> deleteFood(String foodId) async 
  {
    var dbClient = await db;

    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [foodId]);
  }

  Future<Food> readFood(String foodId) async 
  {
    var dbClient = await db;

    List<Map> maps = await dbClient.query(TABLE, columns: [ID,FOOD_NAME, FOOD_GROUP, DATE_CONSUMED, MEAL_TYPE, NOTES, REPORTER_NAME], where: 'id = ?', whereArgs: [foodId] );

    Food food;

    if (maps.length > 0) 
    {
      for (int i = 0; i < maps.length; i++) 
      {
        food = (Food.fromMap(maps[i]));
      }
    }

    return food;
  }
 
  Future close() async 
  {
    var dbClient = await db;

    dbClient.close();
  }
}