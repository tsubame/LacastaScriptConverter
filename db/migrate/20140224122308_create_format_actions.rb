class CreateFormatActions < ActiveRecord::Migration
  def change
    create_table :format_actions do |t|

      t.timestamps
    end
  end
end
