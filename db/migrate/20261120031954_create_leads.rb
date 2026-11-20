class CreateLeads < ActiveRecord::Migration[8.1]
  def change
    create_table :leads do |t|
      t.references :contact, null: false, foreign_key: true, index: { unique: true }
      t.references :category, null: false, foreign_key: true
      t.string :status, null: false, default: "backlog"
      t.text :notes

      t.timestamps
    end
  end
end
