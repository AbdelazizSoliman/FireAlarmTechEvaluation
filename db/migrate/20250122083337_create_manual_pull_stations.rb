class CreateManualPullStations < ActiveRecord::Migration[7.1]
  def change
    create_table :manual_pull_stations do |t|
      t.string :type
      t.integer :break_glass
      t.integer :break_glass_weather_proof
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
