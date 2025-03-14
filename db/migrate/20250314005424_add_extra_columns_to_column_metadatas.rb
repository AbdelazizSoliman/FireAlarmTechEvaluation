class AddExtraColumnsToColumnMetadatas < ActiveRecord::Migration[7.1]
  def change
    add_column :column_metadatas, :sub_field, :string
    add_column :column_metadatas, :rate_key, :string
    add_column :column_metadatas, :amount_key, :string
    add_column :column_metadatas, :notes_key, :string
  end
end
