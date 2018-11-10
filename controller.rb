require 'sinatra'
require 'sinatra/activerecord'

class User < ActiveRecord::Base
	has_many :devices #for token / multi devices
    has_many :myanimals 
    has_many :coinpayments
    has_many :animalpayments
    has_many :upgrades, through: :myanimal #관계가 성립안됨 
end

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