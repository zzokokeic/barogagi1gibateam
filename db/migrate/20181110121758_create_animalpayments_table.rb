class CreateAnimalpaymentsTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :animalpayments do |a|
  		a.integer	:user_id
  		a.integer	:coin_paid
  		a.datetime	:created_at
  	end
  end
end
