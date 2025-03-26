class AddTotalNoOfNurseStationTerminalToNurseStationTerminalModule < ActiveRecord::Migration[7.1]
  def change
    add_column :nurse_station_terminal_module, :total_no_of_nurse_station_terminal, :integer
  end
end
