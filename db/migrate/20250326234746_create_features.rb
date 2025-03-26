        class CreateFeatures < ActiveRecord::Migration[7.1]
          def change
            create_table :features, force: :cascade do |t|
              t.references :parent, null: false, foreign_key: { to_table: :nurse_station_terminal }
              t.bigint :subsystem_id, null: false
              t.bigint :supplier_id, null: false
              t.timestamps
              t.index [:subsystem_id], name: "index_features_on_subsystem_id"
              t.index [:supplier_id, :subsystem_id], name: "idx_features_sup_sub", unique: true
              t.index [:supplier_id], name: "index_features_on_supplier_id"
            end
          end
        end
