# app/models/column_metadata.rb
class ColumnMetadata < ApplicationRecord
  before_validation :assign_default_positions, on: :create

  validates :table_name, :column_name, presence: true
  validates :row, :col, :label_row, :label_col, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  self.table_name = 'column_metadatas'
  
  private

  def assign_default_positions
    # col / label_col are always 1 / 0
    self.col       ||= 1
    self.label_col ||= 0

    # find the highest existing row for this table, then +1
    max_row = ColumnMetadata.where(table_name: table_name).maximum(:row) || 0
    self.row       ||= max_row + 1
    self.label_row ||= row
  end
end
