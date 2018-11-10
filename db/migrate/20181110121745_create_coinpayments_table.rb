class CreateCoinpaymentsTable < ActiveRecord::Migration[5.2]
  def change
  	create_table :coinpayments do |c|
  		c.integer	:user_id
  		c.integer	:cash_amount
  		c.integer	:coin_amount
  		c.datetime	:created_at
  	end
  end
end
