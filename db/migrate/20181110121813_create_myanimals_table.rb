class CreateMyanimalsTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :myanimals do |ma|
  		ma.integer	:user_id
  		ma.integer	:animal_id
  		ma.integer	:habit_id
  		ma.integer	:coin_paid
  		ma.integer	:growth_step
  		ma.boolean	:upgrade_done
  		ma.boolean	:is_deleted
  		ma.datetime	:created_at
  	end
  end
end
