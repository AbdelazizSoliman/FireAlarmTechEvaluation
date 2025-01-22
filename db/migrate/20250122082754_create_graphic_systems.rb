class CreateGraphicSystems < ActiveRecord::Migration[7.1]
  def change
    create_table :graphic_systems do |t|
      t.string :workstation
      t.string :workstation_control_feature
      t.string :softwares
      t.string :licenses
      t.string :screens
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
