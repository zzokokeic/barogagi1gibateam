require 'sinatra'
require './db_class.rb'
require 'bcrypt'


############# Function definition
# Sukjung
post '/sign_up' do

    if params["nickname"].nil?
        return "error_1_1".to_json # Enter Nickname
    elsif params["password"].nil?
        return "error_1_2".to_json # Enter Password
    elsif params["password_confirm"].nil?
        return "error_1_3".to_json # Enter Password_confirm
    elsif params["email"].nil?
        return "error_1_4".to_json # Enter Email
    elsif params["upgrade_password"].nil?
        return "error_1_5".to_json # Enter Upgrade_password
    end

    # substring => @ and .
    unless User.where("nickname" => params["nickname"]).take.nil?
        return "error_1_6".to_json # Nickname is in use. Enter another nickname.
    end

    unless User.where("email" => params["email"]).take.nil?
        return "error_1_7".to_json # Email is in use. Enter another Email.
    end

    if params["nickname"].length < 2
        return "error_1_8".to_json # Nickname should be longer than 2 syllables
    end

    if params["password"].length < 6
        return "error_1_9".to_json # Password should be longer than 6 syllables
    end

    unless params["upgrade_password"].length == 4
        return "error_1_10".to_json # Upgrade Password should be 4 syllables
    end

    unless params["password"] == params["password_confirm"]
        return "error_1_11".to_json # Check the Password
    end

    unless params["email"].include? "@" && params["email"].include? "."
        return "error_1_12" # Check Email address
    end

    user = User.new
    user.nickname = params["nickname"]
    user.email = params["email"]
    user.password = BCrypt::Password.create(params["password"])
    user.upgrade_password = params["upgrade_password"]
    user.current_coin = 0
    user.max_myanimal = 3
    user.created_at = Time.now
    user.save

    device = Device.new
    device.user = user 
    device.token = SecureRandom.uuid #https://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html
    device.save

    return device.to_json
end

#Sukjung
post '/sign_in' do # error_2

    user = User.find_by_email(params["email"])

    if user.nil?
        return "error_2_1".to_json # 
    end
    
    unless BCrypt::Password.new(user.password) == params["password"]
        return "error_2_2".to_json # 
    end

    device = Device.new
    device.user = user
    device.token = SecureRandom.uuid
    device.save
    return device.to_json
end

# duhee
post '/buy_coin' do #error3
    # 결제모듈과 연결
    # https://www.iamport.kr/getstarted
    # fuse에서!
end

# duhee
get '/get_coin_payment' do #error4
    user = Device.find_by_token(params["token"]).user
    # https://github.com/mislav/will_paginate

    user.coinpayments.to_json
end

# sori
get '/get_animal_list' do  #error5
    return Animal.all.to_json
end

# jinju
post '/get_my_animal_list' do #error6
    user = Device.find_by_token(params["token"]).user

    if user.nil?
        return "error_6_1".to_json
    else
        animals = user.myanimals
        if animals.nil?
            return "error_6_2".to_json
        else
            if !params["is_deleted"].nil?
              animals = animals.where("is_deleted" => params["is_deleted"])
            end

            if !params["upgrade_done"].nil?
              animals = animals.where("upgrade_done" => params["upgrade_done"])
            end

            return animals.to_json
        end
    end
end

# sori
get '/get_habit_list' do #error7
    return Habit.all.to_json
end

# jinju
post '/buy_animal' do #error8
    user = Device.find_by_token(params["token"]).user
    animal = Animal.find(params["animal_id"])
    habit = Habit.find(params["habit_id"])

    if user.nil?
        return "error_8_1".to_json
    elsif animal.nil?
        return "error_8_2".to_json
    elsif habit.nil?
        return "error_8_3".to_json
    else
        if user.current_coin < animal.coin_price
            return "error_8_4".to_json 
        else
            myanimal = Myanimal.new
            myanimal.user = user
            myanimal.coin_paid = animal.coin_price
            myanimal.is_deleted = false
            myanimal.upgrade_done = false
            myanimal.growth_step = 0
            myanimal.animal = animal
            myanimal.habit = habit
            myanimal.save

            user.current_coin = user.current_coin - animal.coin_price.to_i
            user.save

            return myanimal.to_json
        end
    end
end 

# WJchung
post '/animal_upgrade' do #error9
    user = Device.find_by_token(params["token"]).user
    # myanimal = Myanimal.find(params["myanimal_id"])
    myanimal = user.myanimals.where("id" => params["myanimal_id"]).take
    # myanimal = user.myanimals.find(params["myanimals_id"])
    upgrade = Upgrade.new

    if params["upgrade_password"] != user.upgrade_password
        return "error_9".to_json #wrong upgrade password
    end

    if myanimal.growth_step == myanimal.animal.max_step 
        return "error_9_1".to_json #fully upgraded and cannot further upgrade
    end

    myanimal.growth_step += 1
    if myanimal.growth_step >= myanimal.animal.max_step
        myanimal.growth_step = myanimal.animal.max_step # safety code
        myanimal.upgrade_done = true
    end

    upgrade.myanimal = myanimal
    upgrade.growth_step = myanimal.growth_step
    upgrade.save
    myanimal.save
    myanimal.to_json
end

#HHS
get '/get_notice' do
    return Notice.all.to_json
end

# HHS
post '/logout' do
    Device.find_by_token(params["token"]).delete
    return true.to_json
end

# HHS
post '/secession' do
    user = Device.find_by_token(params["token"]).user
    if user.password != params["password"]
        return "error_6".to_json
    else
        user.delete
        return true.to_json 
    end
end

#finding upgrade password #wjchung
post '/find_lost_password' do #error14
    user = Device.find_by_token(params["token"]).user  #check user
    password = params["password"] 

#click find password and request input account password
    if BCrypt::Password.new(user.password) == params["password"]  
        return user.upgrade_password.to_json
    else 
        return "error_14".to_json #wrong upgrade password 
    end
end