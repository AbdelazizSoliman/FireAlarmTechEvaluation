# app/models/column_metadata.rb
class ColumnMetadata < ApplicationRecord
  before_validation :assign_default_positions, on: :create

  validates :table_name, :column_name, presence: true
  validates :row, :col, :label_row, :label_col,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  private

  def assign_default_positions
    # always force col / label_col if blank
    self.col       = 1 if col.blank?
    self.label_col = 0 if label_col.blank?

    # find highest existing row for this table, defaulting to 0
    max_row = ColumnMetadata.where(table_name: table_name).maximum(:row).to_i
    # only set row & label_row when blank
    self.row       = max_row + 1 if row.blank?
    self.label_row = row       if label_row.blank?
  end
end
