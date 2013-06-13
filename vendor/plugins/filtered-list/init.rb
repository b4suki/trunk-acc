require 'filtered_list'
ActiveRecord::Base.extend FilteredList::FilterFind
ActionView::Base.send :include, FilteredList::Helper