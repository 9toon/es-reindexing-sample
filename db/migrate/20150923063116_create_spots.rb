class CreateSpots < ActiveRecord::Migration
  def change
    create_table :spots do |t|
      t.string :name
      t.string :address
      t.decimal :lat, precision: 9, scale: 6
      t.decimal :lon, precision: 9, scale: 6

      t.timestamps null: false
    end
  end
end
