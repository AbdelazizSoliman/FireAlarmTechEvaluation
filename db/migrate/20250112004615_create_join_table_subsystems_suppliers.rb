class CreateJoinTableSubsystemsSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_join_table :subsystems, :suppliers do |t|
      # t.index [:subsystem_id, :supplier_id]
      # t.index [:supplier_id, :subsystem_id]
    end
  end
end
