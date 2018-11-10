class CreateDevicesTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :devices do |d|
  		d.integer	:user_id
  		d.uuid	:token
  		d.datetime	:created_at
  	end
  end
end
