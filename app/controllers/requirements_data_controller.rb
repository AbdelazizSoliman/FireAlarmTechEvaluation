class RequirementsDataController < ApplicationController
    require 'roo'
    require 'axlsx'
  
    FILE_PATH = Rails.root.join('lib', 'standards.xlsx')  # ✅ Path to Excel file
  
    # ✅ Display Data in Table
    def index
      @sheets_data = read_all_sheets_data
    end
  
    # ✅ Update Data & Save Back to Excel
    def update
      updated_data = params.require(:sheets_data).permit! # ✅ Permit all parameters
    
      if write_to_excel(updated_data.to_h) # ✅ Convert safely to Hash
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
  
    # ✅ Read Data from All Sheets in Excel
    def read_all_sheets_data
      spreadsheet = Roo::Excelx.new(FILE_PATH)
      sheets_data = {}
  
      spreadsheet.sheets.each do |sheet_name|
        sheet = spreadsheet.sheet(sheet_name)
        data = []
        (2..sheet.last_row).each do |row_num|  # Start from row 2 (skip headers)
          row_data = {}
          (1..sheet.last_column).each do |col_num|
            row_data[col_num] = sheet.cell(row_num, col_num)
          end
          data << row_data
        end
        sheets_data[sheet_name] = data
      end
  
      sheets_data
    end
  
    # ✅ Write Updated Data to Excel
    def write_to_excel(sheets_data)
      begin
        Axlsx::Package.new do |p|
          p.workbook do |wb|
            sheets_data.each do |sheet_name, rows|
              rows = rows.to_h if rows.is_a?(ActionController::Parameters) # ✅ Convert to Hash
              
              wb.add_worksheet(name: sheet_name) do |sheet|
                unless rows.empty?
                  first_row = rows.values.first
                  headers = first_row.keys.map(&:to_s) # ✅ Extract headers properly
                  sheet.add_row headers
                end
    
                rows.values.each do |row|
                  sheet.add_row row.values
                end
              end
            end
          end
    
          p.serialize(FILE_PATH)  # ✅ Save Excel file
        end
        Rails.logger.info "✅ Excel file saved successfully!"
        return true
      rescue StandardError => e
        Rails.logger.error "❌ Excel Write Error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        return false
      end
    end
    
    

  end
  