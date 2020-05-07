import 'package:Dietryz/services/db_helper.dart';
import 'package:Dietryz/services/food.dart';
import 'package:Dietryz/screens/food_add.dart';
import 'package:flutter/material.dart';

import 'edit_food.dart';


class FoodDisplay extends StatefulWidget 
{
  FoodDisplay({this.title});

  final String title;

  @override
  _FoodDisplayState createState() => _FoodDisplayState();
}

class _FoodDisplayState extends State<FoodDisplay> 
{
  bool _isLoading = false;

  List<Food> savedFoods;

  List<Food>  savedFoodsList;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var dbHelper;

  @override
  void initState()
  {
    super.initState();
    fetchDetails();
  }

  fetchDetails() async
  {
    setState(() {
      _isLoading = true;
    });
    dbHelper = new DBHelper();
    await fetchSavedFoods();
  }

  fetchSavedFoods() async
  {
    savedFoods  = await dbHelper.getAllFoods();

    print(savedFoods);

    savedFoodsList = new List<Food>();

    if(savedFoods != null && savedFoods.length > 0)
    {
      for(var i = 0; i < savedFoods.length ; i++)
      {
        savedFoodsList.add(savedFoods[i]);
      }

      print(savedFoodsList);
    }
    
    setState(() 
    {
      _isLoading = false;
    });
  }

  void showDeletePrompt(String foodId) 
   {
    showDialog(
    context: context,
    builder: (BuildContext context) 
    {
      return AlertDialog(
        title: Text('Delete Food Item'),
        content: Text('Do you want to remove this Food Item?'),
        actions: <Widget>[
          RaisedButton(
            onPressed: () 
            {
              deleteFoodItem(foodId);
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          RaisedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
        ],
      );
      
    });
  }

  deleteFoodItem(String foodId) async 
  {
    int check = await dbHelper.deleteFood(foodId);

    print("check");

    print(check);

    if(check > 0)
    {
      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor:Colors.black, content: Text('Food Item has been deleted Successfully', style: TextStyle(color:Colors.white),),),);
      setState(() {
        _isLoading = true;
      });
      fetchSavedFoods();
      setState(() {
        _isLoading = false;
      });
    }
    else
    {
      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor:Colors.black, content: Text('Something Went Wrong.', style: TextStyle(color:Colors.red),),),);
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: (){
            showSearch(context: context, delegate: DataSearch(foodItems: savedFoodsList));
          })
        ],
      ),
      body: Container(
        // height: MediaQuery.of(context).size.height / 1,
        color: Colors.grey[300],
        child: Column(
          children: <Widget>
          [
            Expanded(
                  child: Container(
                  child: _isLoading ? Center(child: CircularProgressIndicator(
                    // backgroundColor: Colors.orange[500],
                  ))
                  :(savedFoodsList == null || savedFoodsList.length == 0) ? Center(child:Text('No Foods Found', style: TextStyle(color: Colors.black),)) 
                  :ListView.separated(
                  itemCount: (savedFoodsList == null || savedFoodsList.length == 0) ? 0 : savedFoodsList.length,
                  itemBuilder: (context, index) 
                  {
                    return GestureDetector(
                      onLongPress: ()
                      {
                        showDeletePrompt(savedFoodsList[index].id.toString());
                      },
                      onTap: () 
                      {
                        // Fluttertoast.showToast(msg: savedFoodsList[index].id.toString());
                        Navigator.push(context, MaterialPageRoute(builder: (context) 
                        {
                          return UpdateFood(title:'Update Food', foodId:savedFoodsList[index].id.toString());
                        }));

                        // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => UpdateFood(title:'Update Food', foodId:savedFoodsList[index].id.toString())), (Route<dynamic> route) => false);
                      },
                      child: ListTile(
                      title: Text(
                        savedFoodsList[index].foodName,
                        style: TextStyle(
                          color: Colors.black
                        ),
                      ),
                      trailing: Icon(Icons.edit,
                      color:Colors.black
                      ),
                        ),
                    );
                  }, separatorBuilder: (BuildContext context, int index) 
                  {
                      return Divider(thickness: 1,color:Colors.grey[500]);
                  }, 
                  ),
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()
        {
          // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => CreateFood(title:'Add Food')), (Route<dynamic> route) => false);

          Navigator.push(context, MaterialPageRoute(builder: (context) 
          {
            return CreateFood(title:'Add Food');
          }));
        },
        tooltip: 'Add Food',
        child: Icon(Icons.add),
      ), 
    );
  }
}

class DataSearch extends SearchDelegate
{
  List<Food> foodItems;

  DataSearch({@required this.foodItems});

  @override
  ThemeData appBarTheme(BuildContext context) 
  {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) 
  {
    return 
    [
      IconButton(icon: Icon(Icons.clear), onPressed: ()
      {
        query = "";
      })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) 
  {
    return IconButton(icon: AnimatedIcon(icon:AnimatedIcons.menu_arrow, progress: transitionAnimation,), onPressed: ()
    {
      close(context, null);
    });
  }

  @override
  Widget buildResults(BuildContext context) 
  {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) 
  {
    if(query.isNotEmpty)
    {
      final tempList = foodItems.where((item) 
      {
        return item.foodName.startsWith(query);
      }).toList();

      print(tempList);

      if(tempList.isEmpty || tempList.length == 0 || tempList == null)
      {
        return ListTile(
          title: Text('No Food Item Found'),
        );
      }
      else if(tempList != null && tempList.length > 0)
      {
        return ListView.separated(itemBuilder: (context, index)
        => GestureDetector(
          onTap: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (context) 
            {
              return UpdateFood(title:'Update Food', foodId:tempList[index].id.toString());
            }));
          },
                child: ListTile(
            title: Text(
              tempList[index].foodName,
              style: TextStyle(
                color: Colors.black
              ),
            ),
            trailing: Icon(Icons.edit,
            color:Colors.black
            ),
          ),
        ),
        itemCount: tempList.length,
        separatorBuilder: (BuildContext context, int index) 
        {
            return Divider(thickness: 1,color:Colors.grey[500]);
        }, 
        );
      }
    }
    else if(query.isEmpty)
    {
      final suggestionList = foodItems;
      if(suggestionList.isEmpty || suggestionList.length == 0 || suggestionList == null)
      {
        return ListTile(
          title: Text('No Food Item Found'),
        );
      }
      else if(suggestionList != null && suggestionList.length > 0)
      {
        return ListView.separated(itemBuilder: (context, index)
        => GestureDetector(
          onTap: ()
          {
            Navigator.push(context, MaterialPageRoute(builder: (context) 
            {
              return UpdateFood(title:'Update Food', foodId:suggestionList[index].id.toString());
            }));
          },
                child: ListTile(
            title: Text(
              suggestionList[index].foodName,
              style: TextStyle(
                color: Colors.black
              ),
            ),
            trailing: Icon(Icons.edit,
            color:Colors.black
            ),
          ),
        ),
        itemCount: suggestionList.length,
        separatorBuilder: (BuildContext context, int index) 
        {
            return Divider(thickness: 1,color:Colors.grey[500]);
        }, 
        );
      }
    }
  }
}
