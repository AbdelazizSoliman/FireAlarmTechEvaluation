class TelephoneSystem < ApplicationRecord
  belongs_to :subsystem
  belongs_to :supplier
end
