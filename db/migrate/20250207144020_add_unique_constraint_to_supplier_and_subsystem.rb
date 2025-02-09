class AddUniqueConstraintToSupplierAndSubsystem < ActiveRecord::Migration[7.1]
  def change
    tables = {
      supplier_data: "idx_sup_data_sup_sub",
      isolations: "idx_iso_sup_sub",
      door_holders: "idx_door_hold_sup_sub",
      evacuation_systems: "idx_evac_sys_sup_sub",
      fire_alarm_control_panels: "idx_fire_ctrl_sup_sub",
      general_commercial_data: "idx_gen_com_sup_sub",
      graphic_systems: "idx_graph_sys_sup_sub",
      interface_with_other_systems: "idx_iface_sys_sup_sub",
      manual_pull_stations: "idx_manual_pull_sup_sub",
      material_and_deliveries: "idx_mat_del_sup_sub",
      notification_devices: "idx_notif_dev_sup_sub",
      prerecorded_message_audio_modules: "idx_audio_mod_sup_sub", # Shortened index name
      product_data: "idx_prod_data_sup_sub",
      scope_of_works: "idx_scope_works_sup_sub",
      spare_parts: "idx_spare_parts_sup_sub",
      subsystem_suppliers: "idx_subsys_sup_sub",
      telephone_systems: "idx_tel_sys_sup_sub",
      detectors_field_devices: "idx_det_field_sup_sub"
    }

    tables.each do |table, index_name|
      add_index table, [:supplier_id, :subsystem_id], unique: true, name: index_name
    end
  end
end
