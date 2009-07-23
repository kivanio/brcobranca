require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require File.dirname(__FILE__) + '/lib/brcobranca'

Hoe.plugin :newgem
Hoe.plugin :website

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'brcobranca' do
  self.developer('Kivanio Barbosa', 'kivanio@gmail.com')
  self.rubyforge_name       = self.name
  self.extra_deps         = [
    ['rghost','>= 0.8.7'],
    ['rghost_barcode','>= 0.8'],
    ['parseline','>= 1.0.3']
  ]

  # self.rdoc_pattern = /rb$|rdoc$/
  self.summary = 'Gem que permite trabalhar com cobranças via bancos brasileiros.'
  self.description = 'Gem para emissão de bloquetos de cobrança de bancos brasileiros.'
  self.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (self.rubyforge_name == self.name) ? self.rubyforge_name : "\#{self.rubyforge_name}/\#{self.name}"
  self.remote_rdoc_dir = File.join(path.gsub(/^#{self.rubyforge_name}\/?/,''), 'rdoc')
  self.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]