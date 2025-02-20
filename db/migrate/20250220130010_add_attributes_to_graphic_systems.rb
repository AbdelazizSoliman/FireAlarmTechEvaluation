class AddAttributesToGraphicSystems < ActiveRecord::Migration[7.1]
  def change
    add_column :graphic_systems, :screen_inch, :decimal
    add_column :graphic_systems, :color, :string
    add_column :graphic_systems, :life_span, :string
    add_column :graphic_systems, :no_of_buttons, :integer
    add_column :graphic_systems, :no_of_function, :integer
    add_column :graphic_systems, :antibacterial, :boolean
  end
end
