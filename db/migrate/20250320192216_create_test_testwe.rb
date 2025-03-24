      class CreateTestTestwe < ActiveRecord::Migration[7.1]
        def change
          create_table :test_testwe, force: :cascade do |t|
            t.string :testuo_yet
            t.bigint :subsystem_id, null: false
            t.bigint :supplier_id, null: false
            t.datetime :created_at, null: false
            t.datetime :updated_at, null: false
            t.index [:subsystem_id], name: "index_test_testwe_on_subsystem_id"
            t.index [:supplier_id, :subsystem_id], name: "idx_test_testwe_sup_sub", unique: true
            t.index [:supplier_id], name: "index_test_testwe_on_supplier_id"
          end
        end
      end
