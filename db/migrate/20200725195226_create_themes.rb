class CreateThemes < ActiveRecord::Migration[5.2]
  def change
    create_table :themes do |t|
      t.string :title, default: "New Theme"
      t.text :variable_file, default: ""
      t.text :custom_file, default: ""

      t.timestamps
    end
  end
end
