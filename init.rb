require "has_bookmarks"
ActiveRecord::Base.send(:include, SimplesIdeias::Acts::Bookmarks)

require File.dirname(__FILE__) + "/lib/bookmark"