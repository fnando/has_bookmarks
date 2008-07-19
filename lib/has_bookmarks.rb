module SimplesIdeias
  module Acts
    module Bookmarks
      def self.included(base)
        base.extend SimplesIdeias::Acts::Bookmarks::ClassMethods
        
        class << base
          attr_accessor :has_bookmarks_options
        end
      end
      
      module ClassMethods
        def has_bookmarks
          self.has_bookmarks_options = {
            :type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          }
          
          # associations
          has_many :bookmarks, :as => :bookmarkable, :dependent => :destroy
          
          include SimplesIdeias::Acts::Bookmarks::InstanceMethods
        end
      end
      
      module InstanceMethods
        def find_bookmark_by_user(owner)
          owner = owner.id if owner.is_a?(User)
          self.bookmarks.find(:first, :conditions => {:user_id => owner})
        end
        
        def bookmark(options)
          self.bookmarks.create(options)
        end
        
        def remove_bookmark_for(owner)
          bookmark = find_bookmark_by_user(owner)
          return true if bookmark.destroy
          return false
        end
        
        def bookmarked?(owner)
          !find_bookmark_by_user(owner).nil?
        end
        
        def find_users_that_bookmarked(options={})
          options = {
            :limit => 20,
            :conditions => ["bookmarks.bookmarkable_type = ? and bookmarks.bookmarkable_id = ?", self.class.has_bookmarks_options[:type], self.id],
            :include => :bookmarks
          }.merge(options)

          User.find(:all, options)
        end
      end
    end
  end
end