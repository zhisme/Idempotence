class CreateOperations < ActiveRecord::Migration[7.1]
  def change
    create_table :operations do |t|
      t.bigint :total, default: 0, null: false

      t.timestamps
    end
  end
end
