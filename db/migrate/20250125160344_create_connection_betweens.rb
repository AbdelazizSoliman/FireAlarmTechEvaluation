class CreateConnectionBetweens < ActiveRecord::Migration[7.1]
  def change
    create_table :connection_betweens do |t|
      t.string :connection_type
      t.string :network_module
      t.string :cables_for_connection
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
