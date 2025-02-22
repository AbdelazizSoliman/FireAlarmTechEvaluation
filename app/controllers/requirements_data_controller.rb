class RequirementsDataController < ApplicationController
  require 'roo'
  require 'axlsx'
  require 'tempfile'

  # Local temporary file path (only used for writing and as fallback)
  FILE_PATH = Rails.root.join('lib', 'standards.xlsx')

 
  def load_local_excel_data
    spreadsheet = Roo::Excelx.new(FILE_PATH)
    read_all_sheets_data_from(spreadsheet)
  end

   # Display Data in Table
  def index
    doc = StandardFile.first
    if doc&.excel_file&.attached?
      begin
        temp_file = Tempfile.new(["standards", ".xlsx"])
        temp_file.binmode
        temp_file.write(doc.excel_file.download)
        temp_file.rewind
  
        spreadsheet = Roo::Excelx.new(temp_file.path)
        @sheets_data = read_all_sheets_data_from(spreadsheet)
  
        temp_file.close
        temp_file.unlink
      rescue ActiveStorage::FileNotFoundError => e
        Rails.logger.error "ActiveStorage file not found: #{e.message}"
        @sheets_data = load_local_excel_data
        flash[:alert] = "Using local file as fallback because external file is missing."
      end
    else
      @sheets_data = load_local_excel_data
      flash[:alert] = "No external Excel file found. Displaying local data."
    end
  end
  
  

  # Update Data & Save Back to Excel, then persist to Active Storage
  def update
    # Ensure updated_data is defined by requiring and permitting the sheets_data params
    updated_data = params.require(:sheets_data).permit!
    
    if write_to_excel(updated_data.to_h)
      doc = StandardFile.first_or_initialize
      doc.name = "standards.xlsx"
      doc.excel_file.purge if doc.excel_file.attached?
      
      doc.excel_file.attach(
        io: File.open(FILE_PATH),
        filename: "standards.xlsx",
        content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      )
      
      if doc.save
        flash[:notice] = "Excel file updated successfully!"
      else
        flash[:alert] = "Failed to save updated Excel file to external storage."
      end
    else
      flash[:alert] = "Failed to update Excel file."
    end
  
    redirect_to requirements_data_path
  end
  
  

  # Download the Updated Excel File from Active Storage
  def download
    doc = StandardFile.first
    if doc&.excel_file&.attached?
      redirect_to rails_blob_url(doc.excel_file, disposition: "attachment")
    else
      flash[:alert] = "Excel file not found."
      redirect_to requirements_data_path
    end
  end

  private

  # Read Data from local FILE_PATH using Roo (fallback)
  def read_all_sheets_data
    spreadsheet = Roo::Excelx.new(FILE_PATH)
    read_all_sheets_data_from(spreadsheet)
  end

  # Common method to extract data from a given Roo spreadsheet object
  def read_all_sheets_data_from(spreadsheet)
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

  # Write Updated Data to Excel file locally using Axlsx
  def write_to_excel(sheets_data)
    begin
      Axlsx::Package.new do |p|
        p.workbook do |wb|
          sheets_data.each do |sheet_name, rows|
            rows = rows.to_h if rows.is_a?(ActionController::Parameters)
            wb.add_worksheet(name: sheet_name) do |sheet|
              unless rows.empty?
                first_row = rows.values.first
                headers = first_row.keys.map(&:to_s)
                sheet.add_row headers
              end
              rows.values.each do |row|
                sheet.add_row row.values
              end
            end
          end
        end
        p.serialize(FILE_PATH)
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
