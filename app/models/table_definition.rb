class TableDefinition < ApplicationRecord
  validates :table_name, presence: true, uniqueness: true
  validates :subsystem_id, presence: true

  # Optional: add an association if you have a Subsystem model
  # belongs_to :subsystem

  # You could also add a method to check if the table is a main table or a sub-table
  def main_table?
    parent_table.blank?
  end

  def sub_table?
    parent_table.present?
  end
end
