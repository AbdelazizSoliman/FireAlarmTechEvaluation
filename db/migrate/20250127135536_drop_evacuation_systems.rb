class DropEvacuationSystems < ActiveRecord::Migration[7.1]
  def change
    if table_exists?(:evacuation_systems)
      drop_table :evacuation_systems
    end
  end
end
