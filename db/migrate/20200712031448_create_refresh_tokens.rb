class CreateRefreshTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, precision: 6, null: false, index: { unique: true }
      t.string :token, null: false

      t.timestamps
    end
  end
end
