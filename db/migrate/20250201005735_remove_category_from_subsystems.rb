class RemoveCategoryFromSubsystems < ActiveRecord::Migration[7.1]
  def change
    remove_column :subsystems, :category, :string
  end
end
