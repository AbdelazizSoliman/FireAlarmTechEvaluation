class RemoveCategoryFromSubsystems < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:subsystems, :category)
      remove_column :subsystems, :category, :string
    end
  end
end