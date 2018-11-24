class CreateUpgradesTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :upgrades do |u|
  		u.integer	:myanimal_id
  		u.integer	:growth_step
  		u.datetime	:created_at
  	end
  end
end
