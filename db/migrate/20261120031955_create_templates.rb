class CreateTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :templates do |t|
      t.references :category, null: false, foreign_key: true, index: { unique: true }
      t.text :body, null: false

      t.timestamps
    end
  end
end
