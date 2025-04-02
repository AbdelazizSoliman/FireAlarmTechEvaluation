class RemoveStaffConsolesModuleTypeFromNurseStationTerminalModule < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:nurse_station_terminal_module, " Staff Consoles Module Type")
      remove_column :nurse_station_terminal_module, " Staff Consoles Module Type", :string
    elsif column_exists?(:nurse_station_terminal_module, :staff_consoles_module_type)
      remove_column :nurse_station_terminal_module, :staff_consoles_module_type, :string
    end
  end
end
