require 'sinatra'
require 'sinatra/activerecord'
#require 'bcrypt'

# DB definition
# user, device, animalpayment, coinpayment, 
# myanimal, upgrade, animal, habit
class User < ActiveRecord::Base
	has_many :devices #for token / multi devices
    has_many :myanimals 
    has_many :coinpayments
    has_many :animalpayments
    has_many :upgrades, through: :myanimal
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

class Device < ActiveRecord::Base
	belongs_to :user
end

class Coinpayment < ActiveRecord::Base
	belongs_to :user
end

class Animalpayment < ActiveRecord::Base
	belongs_to :user
end

class Myanimal < ActiveRecord::Base
	belongs_to :user
	belongs_to :animal
    belongs_to :habit
    has_many :upgrades
end

class Upgrade < ActiveRecord::Base
	belongs_to :myanimal
    has_one :user, through: :myanimal
end

class Animal < ActiveRecord::Base
	has_many :myanimals 
end

class Habit < ActiveRecord::Base
	has_many :myanimals 
end


# Function definition
post '/sign_up' do #회원가입
    user = User.new
    user.nickname = params["nickname"] 
 	user.email = params["email"]
 	user.password = params["password"]
 	user.upgrade_password = params["upgrade_password"]
 	user.current_coin = 0 #입력받는 값이 아니라 지정값 입니다!
 	user.max_myanimal = 5
 	user.created_at = Time.now
    user.save

	device = Device.new
    device.user = user # user db저장 이후 assign
    device.token = SecureRandom.uuid #https://ruby-doc.org/stdlib-1.9.3/libdoc/securerandom/rdoc/SecureRandom.html
    device.save

    device.to_json
end
     #uuid: 지구상에 하나 밖에 존재하지 않는 아이디로 토큰을 만들어줘야 함(추측불가해야함)
     #uuid ruby

post '/sign_in' do #로그인
    user = User.where("id" => params["id"]).where("password" => params["password"]).take

    if user.nil?
        return "error_1".to_json # 로그인 실패
    end

    device = Device.new
    device.user = user
    device.token = SecureRandom.uuid
    device.save
    device.to_json
end

post '/buy_coin' do
    # 결제모듈과 연결
    # https://www.iamport.kr/getstarted
end

get '/get_coin_payment' do
    user = Device.find_by_token(params["token"]).user
    # https://github.com/mislav/will_paginate

    user.coinpayments.to_json
end

get '/get_animal_list' do 
    Animal.all.to_json
end

get '/get_my_animal_list' do
    user = Device.find_by_token(params["token"]).user

    animals = user.myanimals

    if !params["is_deleted"].nil?
        animals = animals.where("is_deleted" => params["is_deleted"])
    end

    if !params["upgrade_done"].nil?
        animals = animals.where("upgrade_done" => params["upgrade_done"])
    end

    animals.to_json
end

get '/get_habit_list' do
    Habit.all.to_json
end

post '/buy_animal' do #물고기를 샀을 때 저장해야 할 정보들!
    user = Device.find_by_token(params["token"]).user
    animal = Animal.find(params["animal_id"])
    habit = Habit.find(params["habit_id"])

    if animal.nil? || habit.nil?
        return "error_5".to_json #유효한 값인지 체크
    end

    if user.coin_amount < animal.coin_price
        return "error_1".to_json #결제연결은 fuse에서
    end

    myanimal = Myanimal.new
    myanimal.user = user
    myanimal.coin_paid = animal.coin_price
    myanimal.is_deleted = false
    myanimal.upgrade_done = false
    myanimal.growth_steps = 0
    myanimal.animal = animal
    myanimal.habit = habit
    myanimal.save
    # myanimal = Myanimal.create("user"=>user, "coin_paid"=>animal.coin_price, "is_deleted"=>) # create = new + save

    #params data type = string!!
    #to_i는 숫자로 변환. 혹시 숫자가 스트링으로 넘어올까봐 변환코드 넣어줌.
    user.coin_amount = user.coin_amount - animal.coin_price.to_i
    user.save

    #마지막 라인이 퓨즈에게 넘겨짐!!
    myanimal.to_json
end 

get '/get_my_animal_list' do
    user = Device.find_by_token(params["token"]).user

    animals = user.myanimals

    if !params["is_deleted"].nil?
        animals = animals.where("is_deleted" => params["is_deleted"])
    end

    if !params["upgrade_done"].nil?
        animals = animals.where("upgrade_done" => params["upgrade_done"])
    end

    animals.to_json
end

post '/animal_upgrade' do
    user = Device.find_by_token(params["token"]).user
    # myanimal = Myanimal.find(params["myanimal_id"])
    myanimal = user.myanimals.where("id" => params["myanimals_id"])
    upgrade = Upgrade.new

    if params["upgrade_password"] != user.upgrade_password
        return "error_3".to_json #업그레이드 비번 다름
    end

    myanimal.growth_steps += 1
    if myanimal.growth_steps >= myanimal.animal.steps
        myanimal.growth_steps = myanimal.animal.steps # 안전장치
        myanimal.upgrade_done = true
    end

    upgrade.myanimal = myanimal
    upgrade.growth_steps = myanimal.growth_steps
    upgrade.save
    myanimal.save
    myanimal.to_json
end

#########################이 아래는 한현상이 썼습니다. ##############################

# Class로 Notice를 선언하고, title, created_at, content를 필드에 추가해야 함
get '/get_notice' do
    Notice.all.to_json
end

post '/logout' do
    #이거 넣어야할까?    user = Device.find_by_token(params["token"]).user
    Device.find_by_token(params["token"]).delete #확실히는 모르겠다.. 근데 여기서 궁금한 점: 토큰이 일치하지 않는 경우에는 자동 로그아웃되고 서비스 메인페이지로 이동시켜야 할 텐데, 이건 우리가 짠 코드에 없는 것 같다?
end

post '/secession' do
    user = Device.find_by_token(params["token"]).user
    if user.password != params["password"]
        return "error_6".to_json # 패스워드를 못맞히는 놈들은 탈퇴시키면 안되니까.
        else
        # finalchance라고 해서, "정말 탈퇴하시겠습니까?" 문구에 yes or no를 선택하게 할 예정.
        if finalchance.nil? # boolean으로 params가 안되는것같으니, nil여부로 해야겠다.
            user.delete #맞남;;;
        end
    end
end

post '/notification' do #정말 전혀모르겠다;
end

#비밀번호 찾기
