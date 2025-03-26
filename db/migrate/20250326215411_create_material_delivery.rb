        class CreateMaterialDelivery < ActiveRecord::Migration[7.1]
          def change
            create_table :material_delivery, force: :cascade do |t|
              t.bigint :subsystem_id, null: false
              t.bigint :supplier_id, null: false
              t.timestamps
              t.index [:subsystem_id], name: "index_material_delivery_on_subsystem_id"
              t.index [:supplier_id, :subsystem_id], name: "idx_material_delivery_sup_sub", unique: true
              t.index [:supplier_id], name: "index_material_delivery_on_supplier_id"
            end
          end
        end
