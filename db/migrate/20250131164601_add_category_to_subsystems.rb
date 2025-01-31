class AddCategoryToSubsystems < ActiveRecord::Migration[7.1]
  def change
    add_column :subsystems, :category, :string
  end
end
