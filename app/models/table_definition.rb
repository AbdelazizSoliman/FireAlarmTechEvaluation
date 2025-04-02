class TableDefinition < ApplicationRecord
  before_create :set_position, if: -> { parent_table.nil? }

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

  private

  def set_position
    # Find the current highest position for main tables in the same subsystem.
    max_position = TableDefinition.where(subsystem_id: subsystem_id, parent_table: nil).maximum(:position) || 0
    self.position = max_position + 1
  end
end
