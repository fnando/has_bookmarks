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
    :polymorphic => true
  
  belongs_to :user
  
  # validations
  validates_presence_of :user_id, :user,
    :message => MESSAGES[:user_is_required]
  
  validates_uniqueness_of :user_id,
    :scope => [:bookmarkable_type, :bookmarkable_id, :name],
    :message => MESSAGES[:has_already_bookmarked]
  
  # callbacks
  after_create    :increment_bookmark_counters
  before_destroy  :decrement_bookmark_counters
  
  private
    def increment_bookmark_counters
      counter_name = "#{name}_bookmarks_count"
      bookmarkable.class.increment_counter(counter_name, bookmarkable.id) if bookmarkable.respond_to?(counter_name)
      bookmarkable.class.increment_counter(:bookmarks_count, bookmarkable.id) if bookmarkable.respond_to?(:bookmarks_count)
    end
    
    def decrement_bookmark_counters
      counter_name = "#{name}_bookmarks_count"
      bookmarkable.class.decrement_counter(counter_name, bookmarkable.id) if bookmarkable.respond_to?(counter_name)
      bookmarkable.class.decrement_counter(:bookmarks_count, bookmarkable.id) if bookmarkable.respond_to?(:bookmarks_count)
    end
end