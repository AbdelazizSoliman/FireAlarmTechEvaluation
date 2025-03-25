      class CreateTestDynamically < ActiveRecord::Migration[7.1]
        def change
          create_table :test_dynamically, force: :cascade do |t|
            t.string :test1
            t.bigint :subsystem_id, null: false
            t.bigint :supplier_id, null: false
            t.datetime :created_at, null: false
            t.datetime :updated_at, null: false
            t.index [:subsystem_id], name: "index_test_dynamically_on_subsystem_id"
            t.index [:supplier_id, :subsystem_id], name: "idx_test_dynamically_sup_sub", unique: true
            t.index [:supplier_id], name: "index_test_dynamically_on_supplier_id"
          end
        end
      end
