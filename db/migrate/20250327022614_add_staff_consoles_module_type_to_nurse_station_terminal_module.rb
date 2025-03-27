class AddStaffConsolesModuleTypeToNurseStationTerminalModule < ActiveRecord::Migration[7.1]
  def change
    add_column :nurse_station_terminal_module, :staff_consoles_module_type, :string
  end
end
