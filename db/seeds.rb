
# 공용으로 사용할 DB
# for문으로 만들면 될 것 같음

#command+/ : 주석처리
# \ : 다음줄로 넘어갈때 쳐주면 됨!
#1depth: user, habit, animal
#2depth: myanimal, device
#3depth: upgrade

for i in 1..9
    User.create("nickname"=>"유저#{i}", "email"=>"#{i}@gmail.com", \
        "password"=>"abc#{i}#{i}#{i}#{i}", "upgrade_password"=>"#{i}#{i}#{i}#{i}", \
        "current_coin"=>0, "max_myanimal"=>3, "created_at"=>Time.now())
    
    ["5~6세","7~8세","9~10세"].each do |t|
        Habit.create("mission"=>"습관#{i}", "category"=>t)
    end

    Animal.create("still_image"=>"still#{i}", "moving_image"=>"moving#{i}", \
        "coin_price"=>rand(3..7), "growth_step"=>rand(6..10))    

    a=Animal.find_by_id(i)
    b=User.find_by_id(i)
    c=Habit.find_by_id(i)
    Myanimal.create("user_id"=>b.id, "animal_id"=>a.id, "habit_id"=>c.id, \
         "coin_paid"=>a.coin_price, "growth_step"=>a.growth_step, "upgrade_done"=>false, "is_deleted"=>false, \
         "created_at"=>Time.now())

end
