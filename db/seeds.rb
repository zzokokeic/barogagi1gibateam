
# 공용으로 사용할 DB
# for문으로 만들면 될 것 같음


# animal
animal = Animal.new
animal.still_image = ""
animal.moving_image = ""
animal.coin_price = 100
animal.growth_step = 5
animal.save

puts "animal_done" #확인로그용


# habit
habit = Habit.new
habit.mission = "habitname"
habit.category = "habitcategory"
habit.save

puts "habit_done" #확인로그용