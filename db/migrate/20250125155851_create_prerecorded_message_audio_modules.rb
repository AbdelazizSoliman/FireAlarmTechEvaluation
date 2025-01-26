class CreatePrerecordedMessageAudioModules < ActiveRecord::Migration[7.1]
  def change
    create_table :prerecorded_message_audio_modules do |t|
      t.string :message_type
      t.integer :total_time_for_messages
      t.integer :total_no_of_voice_messages
      t.string :message_storage_location
      t.string :master_microphone
      t.references :subsystem, null: false, foreign_key: true

      t.timestamps
    end
  end
end
