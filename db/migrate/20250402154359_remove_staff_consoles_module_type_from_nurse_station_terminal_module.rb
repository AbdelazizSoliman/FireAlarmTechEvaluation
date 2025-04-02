class RemoveStaffConsolesModuleTypeFromNurseStationTerminalModule < ActiveRecord::Migration[7.1]
  def change
    remove_column :nurse_station_terminal_module, " Staff Consoles Module Type", :string
  end
end
