class CreateNoticesTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :notices do |n|
  		n.string	:content
  		n.string	:category
  		n.datetime	:created_at
  	end
  end
end
