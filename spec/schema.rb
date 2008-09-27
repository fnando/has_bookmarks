ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :name
  end
  
  create_table :beers do |t|
    t.string :name
    t.integer :bookmarks_count, :default => 0, :null => false
  end
  
  create_table :donuts do |t|
    t.string :flavor
    t.integer :bookmarks_count, :default => 0, :null => false
  end
  
  create_table :bookmarks do |t|
    t.references :bookmarkable, :polymorphic => true
    t.references :user
    t.string :name, :default => nil, :null => true
    t.timestamps
  end
end