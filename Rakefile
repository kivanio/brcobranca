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

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ["--sort coverage", "--exclude /gems/,/Library/"]
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
    config.metrics  = [:churn, :saikuro, :flay, :flog, :reek, :roodi, :rcov]
    config.graphs   = [:flay, :reek]
    config.flay     = { :dirs_to_flay => ['lib'], :minimum_score => 20, :filetypes => ['rb'] }
    config.flog     = { :dirs_to_flog => ['lib'] }
    config.reek     = { :dirs_to_reek => ['lib'] }
    config.roodi    = { :dirs_to_roodi => ['lib'] }
    config.saikuro  = { :output_directory => 'scratch_directory/saikuro', :input_directory => ['lib'],
                        :cyclo => "", :filter_cyclo => "0", :warn_cyclo => "5", :error_cyclo => "7",
                        :formater => "text"} #this needs to be set to "text"
    config.churn    = { :start_date => "3 year ago", :minimum_churn_count => 10}
    config.rcov     = { :test_files => ['spec/**/*_spec.rb'],
                        :rcov_opts => ["--sort coverage", "--no-html", "--text-coverage",
                                       "--no-color", "--profile", "--rails",
                                       "--exclude /gems/,/Library/,spec,features,script"]}
  end
rescue LoadError
end
