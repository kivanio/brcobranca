# -*- encoding: utf-8 -*-
require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "brcobranca"
    gem.summary = %Q{Gem que permite trabalhar com bloquetos de cobrança para bancos brasileiros.}
    gem.description = %Q{Gem para emissão de bloquetos de cobrança de bancos brasileiros.}
    gem.email = "kivanio@gmail.com"
    gem.homepage = "http://github.com/kivanio/brcobranca"
    gem.authors = ["Kivanio Barbosa"]
    gem.requirements << 'GhostScript > 8.0, para gear PDF e código de Barras'
    gem.add_runtime_dependency("rghost", ">= 0.8.7")
    gem.add_runtime_dependency("rghost_barcode", ">= 0.8")
    gem.add_runtime_dependency("parseline", ">= 1.0.3")
    gem.add_runtime_dependency("activemodel", ">= 3.0.0")
    gem.add_development_dependency "rspec", "= 1.3.0"
    gem.add_development_dependency "yard", ">= 0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
  spec.rcov_opts = ["--sort coverage", "--exclude /gems/,/Library/,features,script"]
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

begin
  gem 'metric_fu'
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
    #define which metrics you want to use
    config.metrics  = [:churn, :saikuro, :flay, :flog, :reek, :roodi]
    config.graphs   = []
    config.flay     = { :dirs_to_flay => ['lib'], :minimum_score => 20, :filetypes => ['rb'] }
    config.flog     = { :dirs_to_flog => ['lib'] }
    config.reek     = { :dirs_to_reek => ['lib'] }
    config.roodi    = { :dirs_to_roodi => ['lib'] }
    config.saikuro  = {
      :output_directory => 'scratch_directory/saikuro', :input_directory => ['lib'],
      :cyclo => "", :filter_cyclo => "0", :warn_cyclo => "5", :error_cyclo => "7",
      :formater => "text"
    }
    config.churn    = { :start_date => "3 year ago", :minimum_churn_count => 10}
  end
rescue LoadError
end
