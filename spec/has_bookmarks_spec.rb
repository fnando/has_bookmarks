require "spec_helper"

# unset models used for testing purposes
Object.unset_class('User', 'Beer', 'Donut')

class User < ActiveRecord::Base
  has_many :bookmarks, :dependent => :destroy
end

class Beer < ActiveRecord::Base
  has_bookmarks
end

class Donut < ActiveRecord::Base
  has_bookmarks
end

describe "has_bookmarks" do
  fixtures :users, :beers, :donuts
  
  before(:each) do
    @user = users(:homer)
    @another_user = users(:barney)
    @beer = beers(:duff)
    @donut = donuts(:cream)
  end
  
  it "should have bookmarks association" do
    lambda { @beer.bookmarks }.should_not raise_error
    lambda { @donut.bookmarks }.should_not raise_error
  end
  
  it "should create a bookmark with <user> object" do
    lambda do
      @beer.bookmark(:user => @user)
    end.should change(Bookmark, :count).by(1)
  end
  
  it "should create a bookmark with :user_id attribute" do
    lambda do
      @beer.bookmark(:user_id => @user.id)
    end.should change(Bookmark, :count).by(1)
  end

  it "should require user" do
    lambda do
      bookmark = @beer.bookmark(:user => nil)
      bookmark.errors.on(:user).should_not be_nil
      
      bookmark = @beer.bookmark(:user_id => nil)
      bookmark.errors.on(:user).should_not be_nil
    end.should_not change(Bookmark, :count)
  end
  
  it "should deny duplicated bookmarks with object as scope" do
    lambda do
      bookmark = @beer.bookmark(:user => @user)
      bookmark.should be_valid
      
      another_bookmark = @beer.bookmark(:user => @user)
      another_bookmark.should_not be_valid
    end.should change(Bookmark, :count).by(1)
  end
  
  it "should create bookmark for different objects" do
    lambda do
      bookmark = @beer.bookmark(:user => @user)
      bookmark.should be_valid
      
      another_bookmark = @donut.bookmark(:user => @user)
      another_bookmark.should be_valid
    end.should change(Bookmark, :count).by(2)
  end
  
  it "should create bookmarks for different objects with different users" do
    lambda do
      bookmark = @beer.bookmark(:user => @user)
      bookmark.should be_valid
      
      another_bookmark = @beer.bookmark(:user => @another_user)
      another_bookmark.should be_valid
    end.should change(Bookmark, :count).by(2)
  end
  
  it "should get unique users that bookmarked duff" do
    @beer.bookmark(:user => @user)
    @beer.bookmark(:user => @user)
    @beer.bookmark(:user => @another_user)
    
    @beer.find_users_that_bookmarked.should == [@user, @another_user]
  end
  
  it "should get users that bookmarked only duff" do
    @beer.bookmark(:user => @user)
    @donut.bookmark(:user => @another_user)
    
    @beer.find_users_that_bookmarked.should == [@user]
  end
  
  it "should get users that bookmarked duff as tasty!" do
    @beer.bookmark(:user => @user, :name => 'tasty!')
    @beer.bookmark(:user => @user, :name => 'to-buy')
    @beer.bookmark(:user => @another_user, :name => 'tasty!')
    
    @beer.find_users_that_bookmarked(:name => 'tasty!').should == [@user, @another_user]
  end
  
  it "should get bookmark from a given user" do
    bookmark = @beer.bookmark(:user => @user)
    one_more_bookmark = @donut.bookmark(:user => @user)
    
    @beer.find_bookmark_by_user(:user => @user).should == bookmark
  end
  
  it "should mark beer as bookmarked" do
    @beer.bookmark(:user => @user)
    @beer.should be_bookmarked(:user => @user)
  end
  
  it "should remove bookmark" do
    @beer.bookmark(:user => @user)
    @beer.remove_bookmark_for(:user => @user).should be_true
  end
  
  it "should create bookmark with a name" do
    bookmark = @beer.bookmark(:user => @user, :name => 'tasty!')
    bookmark.should_not be_new_record
    bookmark.name.should == 'tasty!'
  end
  
  it "should set named scope for name" do
    Bookmark.by_name('tasty!').proxy_options.should == {:conditions => ['bookmarks.name = ?', 'tasty!']}
  end
  
  it "should set named scope for user" do
    Bookmark.by_user(1).proxy_options.should == {:conditions => {:user_id => 1}}
  end
  
  it "should return bookmarks by name" do
    bookmark = @beer.bookmark(:user => @user, :name => 'tasty!')
    @beer.bookmark(:user => @user, :name => 'horrible')
    @beer.bookmarks.by_name('tasty!').should == [bookmark]
  end
  
  it "should return paginated users" do
    User.delete_all
    Array(30) do |i| 
      user = User.create!(:name => "User #{i}")
      @beer.bookmark(:user => user)
    end
    
    @beer.find_users_that_bookmarked(:page => 1).should == User.all(:limit => 10)
    @beer.find_users_that_bookmarked(:page => 2).should == User.all(:limit => 10, :offset => 10)
  end
end