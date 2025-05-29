class CreateTempExcelGrids < ActiveRecord::Migration[7.1]
  def change
    create_table :temp_excel_grids do |t|
      t.text :grid_data
      t.string :session_id
      t.bigint :subsystem_id

      t.timestamps
    end
  end
end
