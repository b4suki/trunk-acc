require 'fileutils'
asset_dir = "#{RAILS_ROOT}/vendor/plugins/date_splicer/assets"
FileUtils.cp_r "#{asset_dir}/images/calendar", "#{RAILS_ROOT}/public/images"
FileUtils.cp_r "#{asset_dir}/javascripts/calendar", "#{RAILS_ROOT}/public/javascripts"
FileUtils.cp_r "#{asset_dir}/stylesheets/calendar", "#{RAILS_ROOT}/public/stylesheets"
puts IO.read(File.join(File.dirname(__FILE__), 'README'))
