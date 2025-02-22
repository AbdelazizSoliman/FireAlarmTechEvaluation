class CreateStandardFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :standard_files do |t|
      t.string :name

      t.timestamps
    end
  end
end
