class CreateAnimalsTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :animals do |a|
  		a.integer	:mynimal_id
  		a.string	:still_image
  		a.string	:moving_image
  		a.integer	:coin_price
  		a.integer	:growth_step
  	end
  end
end