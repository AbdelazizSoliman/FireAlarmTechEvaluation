class AddSupplierIdToManualPullStations < ActiveRecord::Migration[7.1]
  def change
    add_reference :manual_pull_stations, :supplier, null: false, foreign_key: true
  end
end
