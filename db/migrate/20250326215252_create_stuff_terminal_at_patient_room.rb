        class CreateStuffTerminalAtPatientRoom < ActiveRecord::Migration[7.1]
          def change
            create_table :stuff_terminal_at_patient_room, force: :cascade do |t|
              t.bigint :subsystem_id, null: false
              t.bigint :supplier_id, null: false
              t.timestamps
              t.index [:subsystem_id], name: "index_stuff_terminal_at_patient_room_on_subsystem_id"
              t.index [:supplier_id, :subsystem_id], name: "idx_stuff_terminal_at_patient_room_sup_sub", unique: true
              t.index [:supplier_id], name: "index_stuff_terminal_at_patient_room_on_supplier_id"
            end
          end
        end
