class CreateUsersTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :users do |u|
      u.string	:nickname
      u.string	:email
      u.string	:password
      u.integer	:upgrade_password
      u.integer	:current_coin
      u.integer	:max_myanimal
      u.datetime	:create_at
  	end
  end
end
