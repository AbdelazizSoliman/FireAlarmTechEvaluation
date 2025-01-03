class CreateGraphicSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :graphic_systems do |t|
      t.string :workstation
      t.string :workstation_control_feature
      t.string :softwares
      t.integer :licenses
      t.string :screens

      t.timestamps
    end
  end
end
