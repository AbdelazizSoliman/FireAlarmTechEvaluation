# app/controllers/evaluation_results_controller.rb
class EvaluationResultsController < ApplicationController
 def index
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])

    # look up all the live metadata-backed column names
    valid_columns = ColumnMetadata
                      .where(table_name: TableDefinition
                                                     .where(subsystem_id: @subsystem.id)
                                                     .pluck(:table_name))
                      .pluck(:column_name)

    @results = EvaluationResult
                 .where(supplier_id:    @supplier.id,
                        subsystem_id:   @subsystem.id)
                 .where(column_name: valid_columns)
                 .order(:table_name, :column_name)
  end

  # POST /evaluation_results/evaluate
  def evaluate
    supplier  = Supplier.find(params[:supplier_id])
    subsystem = Subsystem.find(params[:subsystem_id])

    TableDefinition.where(subsystem_id: subsystem.id).pluck(:table_name).each do |table_name|
      model = Class.new(ActiveRecord::Base) do
        self.table_name        = table_name
        self.inheritance_column = :_type_disabled
      end

      record = model.find_by(supplier_id: supplier.id, subsystem_id: subsystem.id)
      next unless record

      record.attributes.each do |column, submitted|
        # skip metadata columns
        next if %w[id supplier_id subsystem_id created_at updated_at].include?(column)

        meta = ColumnMetadata.find_by(table_name: table_name, column_name: column)
        next unless meta

        # --- COMBOBOX HANDLING ---
        if meta.feature == 'combobox'
          standards = meta.options['combo_standards'] || {}
          setting   = standards[submitted.to_s] || {}

          requirement = setting['requirement']
          kase        = setting['case']
          logic       = setting['logic']

          # crude rule: anything without “no” is fail
          status = requirement.to_s.downcase.include?('no') ? 'pass' : 'fail'
          degree = (status == 'pass' ? 1.0 : 0.0)

          EvaluationResult
            .find_or_initialize_by(
              supplier_id:  supplier.id,
              subsystem_id: subsystem.id,
              table_name:   table_name,
              column_name:  column
            )
            .update!(
              submitted_value: submitted,
              standard_value:  nil,
              tolerance:       nil,
              degree:          degree,
              status:          status,
              combo_case:      kase,
              combo_logic:     logic
            )
          next
        end

        # --- CHECKBOXES HANDLING ---
        if meta.feature == 'checkboxes'
          # normalize the submitted value into an Array of strings
          selected = case submitted
                     when Array then submitted.map(&:to_s)
                     when String then submitted.split(',').map(&:strip)
                     else []
                     end

          # likewise normalize mandatory_values
          raw_mand = meta.options['mandatory_values']
          mandatory = case raw_mand
                      when Array then raw_mand.map(&:to_s)
                      when String then raw_mand.split(',').map(&:strip)
                      else []
                      end

          missing = mandatory - selected
          extra   = selected - mandatory

          if missing.any?
            status = 'fail'
            degree = 0.0
          else
            status = 'pass'
            degree = 1.0 + (extra.size * 0.1)
          end

          EvaluationResult
            .find_or_initialize_by(
              supplier_id:  supplier.id,
              subsystem_id: subsystem.id,
              table_name:   table_name,
              column_name:  column
            )
            .update!(
              submitted_value: selected,
              standard_value:  nil,
              tolerance:       nil,
              degree:          degree,
              status:          status
            )
          next
        end

        # --- NUMERIC HANDLING ---
        next unless meta.standard_value && meta.tolerance

        standard = meta.standard_value.to_f
        tol      = meta.tolerance.to_f
        min_ok   = standard - (standard * tol / 100.0)

        degree, status =
          if submitted.to_f >= standard
            [1.0, 'pass']
          elsif submitted.to_f >= min_ok
            [0.5, 'pass']
          else
            [0.0, 'fail']
          end

        EvaluationResult
          .find_or_initialize_by(
            supplier_id:  supplier.id,
            subsystem_id: subsystem.id,
            table_name:   table_name,
            column_name:  column
          )
          .update!(
            submitted_value: submitted,
            standard_value:  standard,
            tolerance:       tol,
            degree:          degree,
            status:          status
          )
      end
    end

    redirect_to evaluation_results_path(
      supplier_id:  supplier.id,
      subsystem_id: subsystem.id
    ), notice: 'Re-evaluation complete!'
  end

  # GET /evaluation_results/download
  def download
    @supplier  = Supplier.find(params[:supplier_id])
    @subsystem = Subsystem.find(params[:subsystem_id])
    @results   =
      EvaluationResult
        .where(supplier_id:  @supplier.id,
               subsystem_id: @subsystem.id)
        .order(:table_name, :column_name)

    package = Axlsx::Package.new
    raw_name  = "Eval #{@supplier.supplier_name} – #{@subsystem.name}"
    sheet_name = raw_name.gsub(/[\\\/\?\*\[\]]/, '-').slice(0, 31)

    package.workbook.add_worksheet(name: sheet_name) do |sheet|
      sheet.add_row [
        "Attribute",
        "Submitted Value",
        "Standard Value",
        "Tolerance (%)",
        "Degree",
        "Status",
        "Case",
        "Condition/Logic"
      ]
      @results.each do |r|
        sheet.add_row [
          "#{r.table_name}.#{r.column_name}",
          r.submitted_value,
          r.standard_value,
          r.tolerance,
          r.degree,
          r.status,
          r.combo_case,
          r.combo_logic
        ]
      end
    end

    tmp = Tempfile.new(['evaluation', '.xlsx'])
    package.serialize(tmp.path)

    send_file tmp.path,
      filename: "evaluation_#{@supplier.supplier_name}_#{@subsystem.name}.xlsx",
      type:     'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end
end
