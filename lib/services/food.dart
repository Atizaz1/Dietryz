class Food 
{
  int id;

  String foodName;

  String foodGroup;

  String dateConsumed;

  String mealType;

  String notes;

  String reporterName;

  Food.empty();
  
  Food(this.foodName, this.foodGroup, this.dateConsumed, this.mealType, this.notes, this.reporterName);
 
  Map<String, dynamic> toMap() 
  {
    var map = <String, dynamic>
    {
      'food_name'     : this.foodName,

      'food_group'    : this.foodGroup,

      'date_consumed' : this.dateConsumed,

      'meal_type'     : this.mealType,

      'notes'         : this.notes,
      
      'reporter_name' : this.reporterName,
    };

    return map;
  }
 
  Food.fromMap(Map<String, dynamic> map) 
  {
    id            = map['id'];
    
    foodName      = map['food_name'];

    foodGroup     = map['food_group'];

    dateConsumed  = map['date_consumed'];

    mealType      = map['meal_type'];

    notes         = map['notes'];
    
    reporterName  = map['reporter_name'];
  }
}