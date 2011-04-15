# encoding: UTF-8

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

#
# begin
#   gem 'metric_fu'
#   require 'metric_fu'
#   MetricFu::Configuration.run do |config|
#     #define which metrics you want to use
#     config.metrics  = [:churn, :saikuro, :flay, :flog, :reek, :roodi]
#     config.graphs   = []
#     config.flay     = { :dirs_to_flay => ['lib'], :minimum_score => 20, :filetypes => ['rb'] }
#     config.flog     = { :dirs_to_flog => ['lib'] }
#     config.reek     = { :dirs_to_reek => ['lib'] }
#     config.roodi    = { :dirs_to_roodi => ['lib'] }
#     config.saikuro  = {
#       :output_directory => 'scratch_directory/saikuro', :input_directory => ['lib'],
#       :cyclo => "", :filter_cyclo => "0", :warn_cyclo => "5", :error_cyclo => "7",
#       :formater => "text"
#     }
#     config.churn    = { :start_date => "3 year ago", :minimum_churn_count => 10}
#   end
# rescue LoadError
# end
