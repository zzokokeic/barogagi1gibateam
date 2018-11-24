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

=begin
    include BCrypt

    def password
        @password ||= Password.new(password_hash)
    end

    def password=(new_password)
        @password = Password.create(new_password)
        self.password_hash = @password
    end
end
=end

# 암호화하는 방식(BCrypt)
# require 'bcrypt'
# a = BCrypt::Password.create("1234")
# BCrypt::Password.new(a) == "1234"


# 두희
post '/buy_coin' do #error3
    # 결제모듈과 연결
    # https://www.iamport.kr/getstarted
    # fuse에서!
end

# 두희
get '/get_coin_payment' do #error4
    user = Device.find_by_token(params["token"]).user
    # https://github.com/mislav/will_paginate

    user.coinpayments.to_json
end

# sori
get '/get_animal_list' do  #error5
    if Animal.nil?
        return "error_5_1"
    else
        return Animal.all.to_json
    end
end

# jinju
post '/get_my_animal_list' do #error6
    user = Device.find_by_token(params["token"]).user

    if user.nil?
        return "error6_1".to_json
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
    if Habit.nil?
        return "error_7_1"
    else
        return Habit.all.to_json
    end
end

# jinju
post '/buy_animal' do #error8
    user = Device.find_by_token(params["token"]).user
    animal = Animal.find(params["animal_id"])
    habit = Habit.find(params["habit_id"])

    if user.nil?
        return "error8_1".to_json
    elsif animal.nil?
        return "error8_2".to_json
    elsif habit.nil?
        return "error8_3".to_json
    else
        if user.current_coin < animal.coin_price
            return "error8_4".to_json 
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

    if myanimal.growth_step = myanimal.animal.max_step 
        return "error_9_1".to_json #fully upgraded and cannot further upgrade

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

# 현상
# Class로 Notice를 선언하고, title, created_at, content를 필드에 추가해야 함
get '/get_notice' do #error10
    Notice.all.to_json
end

# 현상
post '/logout' do #error11
    #이거 넣어야할까?    user = Device.find_by_token(params["token"]).user
    Device.find_by_token(params["token"]).delete #확실히는 모르겠다.. 근데 여기서 궁금한 점: 토큰이 일치하지 않는 경우에는 자동 로그아웃되고 서비스 메인페이지로 이동시켜야 할 텐데, 이건 우리가 짠 코드에 없는 것 같다?
end

# 현상
post '/secession' do #error12
    user = Device.find_by_token(params["token"]).user
    if user.password != params["password"]
        return "error_6".to_json # 패스워드를 못맞히는 놈들은 탈퇴시키면 안되니까.
    else
        # finalchance라고 해서, "정말 탈퇴하시겠습니까?" 문구에 yes or no를 선택하게 할 예정.
        # if finalchance.nil? # boolean으로 params가 안되는것같으니, nil여부로 해야겠다.
            user.delete #맞남;;;
        return true.to_json 
        # end
    end
end

# 현상
post '/notification' do #정말 전혀모르겠다; #error13
    # 안드로이드 / ios  완전 따로 짜야함
    # Fuse에서!
end

#finding upgrade password #wjchung
post '/get_lost_password' do #error14
    user = Device.find_by_token(params["token"]).user  #check user
    password = params["password"] 

#click find password and request input account password
    if BCrypt::Password.new(user.password) == params["password"]  
        return user.upgrade_password.to_json
    else 
        return "error_14".to_json #wrong upgrade password 
    end
end