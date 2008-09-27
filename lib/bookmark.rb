class Bookmark < ActiveRecord::Base
  # scopes
  named_scope :by_name, lambda { |*name| 
    if name[0]
      {:conditions => ['bookmarks.name = ?', name[0]]}
    else
      {}
    end
  }
  
  named_scope :by_user, lambda { |user_id|
    {:conditions => {:user_id => user_id}}
  }
  
  # constants
  MESSAGES = {
    :user_is_required => "is required",
    :has_already_bookmarked => "has already bookmarked"
  }
  
  # associations
  belongs_to :bookmarkable, 
    :polymorphic => true, 
    :counter_cache => true
  
  belongs_to :user
  
  # validations
  validates_presence_of :user_id, :user,
    :message => MESSAGES[:user_is_required]
  
  validates_uniqueness_of :user_id,
    :scope => [:bookmarkable_type, :bookmarkable_id],
    :message => MESSAGES[:has_already_bookmarked]
end