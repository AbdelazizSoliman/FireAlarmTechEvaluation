class RequirementsDataController < ApplicationController

    require 'roo'
    require 'axlsx'


    FILE_PATH = Rails.root.join('lib', 'standards.xlsx')  # ✅ Define path to Excel file

    # ✅ Display Data in Table
    def index
      @requirements_data = read_requirements_data
    end
  
    # ✅ Update Data & Save Back to Excel
    def update
      updated_data = params[:requirements_data]  # Retrieve updated data from form
  
      if write_to_excel(updated_data)
        flash[:notice] = "Excel file updated successfully!"
      else
        flash[:alert] = "Failed to update Excel file."
      end
  
      redirect_to requirements_data_path
    end
  
    # ✅ Download the Updated Excel File
    def download
      send_file FILE_PATH, filename: "updated_standards.xlsx", type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    end
  
    private
  
    # ✅ Read Data from Excel
    def read_requirements_data
      spreadsheet = Roo::Excelx.new(FILE_PATH)
      sheet = spreadsheet.sheet(0)  # First sheet
  
      data = []
      (2..sheet.last_row).each do |row_num|  # Start from row 2 (skip headers)
        data << {
          id: row_num,
          column1: sheet.cell(row_num, 1),
          column2: sheet.cell(row_num, 2),
          column3: sheet.cell(row_num, 3)
        }
      end
  
      data
    end
  
    # ✅ Write Updated Data to Excel
    def write_to_excel(data)
      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: "Updated Data") do |sheet|
          sheet.add_row ["Column1", "Column2", "Column3"]  # Headers
  
          data.each do |_, row|
            sheet.add_row [row[:column1], row[:column2], row[:column3]]
          end
        end
        p.serialize(FILE_PATH)  # Save the file
      end
      true
    rescue StandardError => e
      Rails.logger.error "❌ Excel Write Error: #{e.message}"
      false
    end

end
