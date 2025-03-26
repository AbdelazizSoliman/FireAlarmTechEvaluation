        class CreateScopeOfWorkSow < ActiveRecord::Migration[7.1]
          def change
            create_table :scope_of_work_sow, force: :cascade do |t|
              t.bigint :subsystem_id, null: false
              t.bigint :supplier_id, null: false
              t.timestamps
              t.index [:subsystem_id], name: "index_scope_of_work_sow_on_subsystem_id"
              t.index [:supplier_id, :subsystem_id], name: "idx_scope_of_work_sow_sup_sub", unique: true
              t.index [:supplier_id], name: "index_scope_of_work_sow_on_supplier_id"
            end
          end
        end
