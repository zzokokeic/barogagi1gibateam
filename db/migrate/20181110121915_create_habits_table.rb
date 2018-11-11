class CreateHabitsTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :habits do |h|
  		h.string	:mission
  		h.string	:category
  	end
  end
end
