# app/models/temp_excel_grid.rb
class TempExcelGrid < ApplicationRecord
  serialize :grid_data, coder: JSON
end