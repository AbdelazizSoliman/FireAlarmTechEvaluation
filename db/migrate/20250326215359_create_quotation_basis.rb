        class CreateQuotationBasis < ActiveRecord::Migration[7.1]
          def change
            create_table :quotation_basis, force: :cascade do |t|
              t.bigint :subsystem_id, null: false
              t.bigint :supplier_id, null: false
              t.timestamps
              t.index [:subsystem_id], name: "index_quotation_basis_on_subsystem_id"
              t.index [:supplier_id, :subsystem_id], name: "idx_quotation_basis_sup_sub", unique: true
              t.index [:supplier_id], name: "index_quotation_basis_on_supplier_id"
            end
          end
        end
