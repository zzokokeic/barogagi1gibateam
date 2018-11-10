class CreateHabitsTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :habits do |h|
  		h.integer	:mynimal_id
  		h.string	:name
  		h.category	:category
  	end
  end
end
