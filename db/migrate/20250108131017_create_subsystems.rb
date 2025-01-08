class CreateSubsystems < ActiveRecord::Migration[7.1]
  def change
    create_table :subsystems do |t|
      t.references :system, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
