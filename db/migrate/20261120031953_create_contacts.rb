class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :company
      t.string :role
      t.string :linkedin_url
      t.text :notes

      t.timestamps
    end
  end
end
