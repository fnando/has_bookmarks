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
        def find_bookmark_by_user(options={})
          return nil unless options[:user_id] || options[:user]
          
          options[:user_id] = options.delete(:user).id if options[:user]
          result = self.bookmarks.by_name(options.delete(:name)).by_user(options.delete(:user_id))
          result[0]
        end
        
        def bookmark(options)
          options[:user_id] = options.delete(:user).id if options[:user]
          self.bookmarks.create(options)
        end
        
        def remove_bookmark_for(options={})
          bookmark = find_bookmark_by_user(options)
          return !!bookmark.destroy unless bookmark.nil? 
          return false
        end
        
        def bookmarked?(options)
          !find_bookmark_by_user(options).nil?
        end
        
        def find_users_that_bookmarked(options={})
          conditions = [
            "bookmarks.bookmarkable_type = ? and bookmarks.bookmarkable_id = ?", 
            self.class.has_bookmarks_options[:type], 
            self.id
          ]
          
          unless options[:name].blank?
            conditions[0] += " and bookmarks.name = ?"
            conditions << options[:name]
            options.delete(:name)
          end
          
          options = {
            :limit => 10,
            :conditions => conditions,
            :include => :bookmarks
          }.merge(options)

          if Object.const_defined?('Paginate')
            User.paginate(options)
          else
            User.all(options)
          end
        end
      end
    end
  end
end