require 'fileutils'
FileUtils.remove_dir "#{RAILS_ROOT}/public/images/calendar"
FileUtils.remove_dir "#{RAILS_ROOT}/public/javascripts/calendar"
FileUtils.remove_dir "#{RAILS_ROOT}/public/stylesheets/calendar"

