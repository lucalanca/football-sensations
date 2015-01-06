class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :result
      t.references :match
      t.string :scorer
      t.string :minute
      t.boolean :own_goal
      t.boolean :penalty
      t.boolean :assist

      t.timestamps null: false
    end
  end
end
