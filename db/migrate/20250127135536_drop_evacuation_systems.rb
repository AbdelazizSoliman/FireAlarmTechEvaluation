class DropEvacuationSystems < ActiveRecord::Migration[7.1]
  def change
    drop_table :evacuation_systems, if_exists: true
  end
end
