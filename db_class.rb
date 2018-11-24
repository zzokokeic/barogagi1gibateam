require 'sinatra/activerecord'
#require 'bcrypt'

############# DB definition
# user, device, coinpayment, myanimal, upgrade, animal, habit, notice
class User < ActiveRecord::Base
	has_many :devices #for token / multi devices
    has_many :myanimals 
    has_many :coinpayments
end

class Device < ActiveRecord::Base
	belongs_to :user
end

class Coinpayment < ActiveRecord::Base
	belongs_to :user
end

class Animal < ActiveRecord::Base
	has_many :myanimals 
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

class Habit < ActiveRecord::Base
	has_many :myanimals 
end

class Notice < ActiveRecord::Base
end