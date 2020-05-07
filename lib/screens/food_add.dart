import 'package:Dietryz/services/db_helper.dart';
import 'package:Dietryz/services/food.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'food_display.dart';

class CreateFood extends StatefulWidget 
{
  CreateFood({this.title});

  final String title;

  @override
  _CreateFoodState createState() => _CreateFoodState();
}

class _CreateFoodState extends State<CreateFood> 
{

  var dbHelper;

  TextEditingController foodGroupController      = new TextEditingController();

  TextEditingController foodNameController       = new TextEditingController();

  TextEditingController dateConsumedController   = new TextEditingController();

  TextEditingController mealTypeController       = new TextEditingController();

  TextEditingController notesController          = new TextEditingController();

  TextEditingController reportController         = new TextEditingController();

  DateTime selectedDate = DateTime.now();

  var dateFormatter = new DateFormat('dd-MM-yyyy');

  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String foodName, foodGroup, dateConsumed, mealType, notes, reporterName;

  Food savedFoodObject;

  Future<Null> _selectDate(BuildContext context) async 
  {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1970, 1),
        lastDate: DateTime(2200));
    if (picked != null && picked != selectedDate)
      setState(() 
      {
        selectedDate = picked;
        dateConsumedController.text = dateFormatter.format(selectedDate);
        print(dateConsumedController.text);
      });
  }

  void formSubmit() async
  {
    final form = _formKey.currentState;

    if (form.validate()) 
    {
      form.save();

      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor:Colors.black, content: Text('Processing. Please Wait!', style: TextStyle(color:Colors.white),),),);

      int check = await dbHelper.findIfFoodExists(foodName);

      if(check > 0)
      {
        _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor:Colors.black, content: Text('Duplicate Food Items cannot be saved', style: TextStyle(color:Colors.red),),),);
      }
      else if(check <=0)
      {
        Food inputFoodObject = new Food(foodName, foodGroup, dateConsumed, mealType, notes, reporterName);

        savedFoodObject = await dbHelper.addFood(inputFoodObject);
      
        if(savedFoodObject != null) 
        {
          setState(() 
          {
            _isLoading = false;
          });

          _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.black87,content: Text('Food Item has been saved Successfully', style: TextStyle(color: Colors.white,),),),);
          
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(BuildContext context) => FoodDisplay(title:'Foods')), (Route<dynamic> route) => false);

        }
        else if(savedFoodObject == null)
        {
          setState(()
          {
            _isLoading = false;
          });

          _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.black87,content: Text('Something Went Wrong. Please Try Again', style: TextStyle(color: Colors.red,),),),);
        }
      }
    }
    else
    {
      _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.black87,content: Text('Unable to process. Incomplete Information!', style: TextStyle(color: Colors.red,),),),);
    }
  }

  @override
  void initState() 
  {
    super.initState();
    dbHelper = new DBHelper();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: _isLoading ? Center(
                child:CircularProgressIndicator(
                  backgroundColor: Colors.white,
              ),
              ) : Container(
                child: Form(
                      key: _formKey,
                      child: ListView(
                      // spacing:4.0,
                      // runSpacing: 1.0, 
                      children: <Widget>[
                        Center(
                          child: Text(
                          'ADD Food',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                          color:Colors.white,
                          fontSize: 20.0,
                          ),
                        ),
                        ),
                        SizedBox(height: 35.0),
                        TextFormField(
                          validator: (value) 
                          {
                              if (value.isEmpty) 
                              {
                                return 'Please Enter Food Name';
                              }
                              else if(value.length < 3)
                              {
                                return 'Food Name can not be short than 3 characters minimum';
                              }
                              else
                                return null;
                          },
                          obscureText: false,
                          onSaved: (value)
                          {
                             foodName = value;
                          },
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          controller: foodNameController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "FoodName",
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                          validator: (value) 
                          {
                              if (value.isEmpty) 
                              {
                                return 'Please Enter Food Group';
                              }
                              else if(value.length < 3)
                              {
                                return 'Food Group can not be short than 3 characters minimum';
                              }
                              else
                                return null;
                          },
                          controller: foodGroupController,
                          onSaved: (value)
                          {
                             foodGroup = value;
                          },
                          obscureText: false,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "FoodGroup",
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                          onSaved: (value)
                          {
                             mealType = value;
                          },
                          obscureText: false,
                          controller: mealTypeController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "MealType",
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                              obscureText: false,
                              onSaved: (value)
                              {
                                dateConsumed = value;
                              },
                              validator: (value) 
                              {
                                if (value.isEmpty) 
                                {
                                  return 'Please Select Consumed Date of the Food';
                                }
                                else
                                  return null;
                              },
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  hintText: "Food Consumed Date",
                            ),
                            controller: dateConsumedController,
                            onTap: () => _selectDate(context),
                            readOnly: true,
                          ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                          textInputAction: TextInputAction.next,
                          onSaved: (value)
                          {
                             notes = value;
                          },
                          obscureText: false,
                          controller: notesController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Notes",
                         ),
                        ),
                        SizedBox(height: 15.0),
                        TextFormField(
                          onSaved: (value)
                          {
                             reporterName = value;
                          },
                          validator: (value) 
                          {
                            if (value.isEmpty) 
                            {
                              return 'Please Enter Reporter\'s Name';
                            }
                            else
                              return null;
                          },
                          obscureText: false,
                          controller: reportController,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Reporter",
                         ),
                        ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: MaterialButton(
                                onPressed: () 
                                {
                                  formSubmit();
                                },
                                minWidth: 150.0,
                                color: Colors.blue,
                                height: 42.0,
                                child: Text(
                                  'Save Food',
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ]
                    ),
                  ),    
            ),
         ),
      ), 
    );
  }
}
