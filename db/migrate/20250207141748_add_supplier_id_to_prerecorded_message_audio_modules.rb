class AddSupplierIdToPrerecordedMessageAudioModules < ActiveRecord::Migration[7.1]
  def change
    add_reference :prerecorded_message_audio_modules, :supplier, null: false, foreign_key: true
  end
end
