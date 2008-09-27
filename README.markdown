has_bookmarks
=============

Instalation
-----------

# Install the plugin with `script/plugin install git://github.com/fnando/has_bookmarks.git`
# Generate a migration with `script/generate migration create_bookmarks` and add the following code:

	class CreateBookmarks < ActiveRecord::Migration
	  def self.up
	    create_table :bookmarks do |t|
	      t.references :bookmarkable, :polymorphic => true
	      t.references :user
	      t.string :name
	      t.timestamps
	    end
    
	    add_index :bookmarks, :bookmarkable_id
	    add_index :bookmarks, :bookmarkable_type
	    add_index :bookmarks, :user_id
	    add_index :bookmarks, :name
	  end

	  def self.down
	    drop_table :bookmarks
	  end
	end

3) Run the migrations with `rake db:migrate`

Usage
-----

1) Add the method call `has_bookmarks` to your model.

	class Product < ActiveRecord::Base
	  has_bookmarks
	end

2) Add this association on your User model:

	class User < ActiveRecord::Base
	  has_many :bookmarks, :dependent => :destroy
	end

	product = Product.first
	user = User.first

	product.bookmark(:user => user) # => <bookmark>
	product.bookmarks # => [<bookmark>]
	product.bookmarked?(:user => user) # => true
	product.find_users_that_bookmarked # => [<user>]
	product.find_bookmark_by_user(:user => user) # => [<bookmark>]
	product.remove_bookmark_for(:user => user)

If you have different types of bookmarks, you can use the option `:name`:

	product.bookmark(:user => user, :name => 'wishlist')
	product.bookmark(:user => user, :name => 'i_have')
	
	product.bookmarks.by_name('wishlist')
	product.bookmarked?(:user => user, :name => 'wishlist')
	product.find_users_that_bookmarked(:name => 'wishlist')
	product.find_bookmark_by_user(:user => user, :name => 'wishlist')
	product.remove_bookmark_for(:user => user, :name => 'wishlist')

If you have [has_paginate](http://github.com/fnando/has_paginate) installed, 
you can paginate the users that bookmarked a given item:

	product.find_users_that_bookmarked(:page => 2)

NOTE: You should have a User model. You should also have a bookmarks_count 
column on your model. **Otherwise, this won't work!**

Copyright (c) 2008 Nando Vieira, released under the MIT license