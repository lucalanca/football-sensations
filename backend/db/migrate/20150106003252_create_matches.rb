class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :home_team_id, null: false
      t.integer :away_team_id, null: false
      t.datetime :kickoff
      t.string :result, null: false, default: '0-0'
      t.string :home_form
      t.string :away_form
      t.integer :fixture
      t.string :highlight_video
      t.references :competition, index: true
      t.string :stadium

      t.timestamps null: false
    end
    add_index :matches, :home_team_id
    add_index :matches, :away_team_id
    add_foreign_key :matches, :competitions
  end
end
