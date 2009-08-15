require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/brcobranca'

Hoe.plugin :newgem
Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'brcobranca' do
  self.developer 'Kivanio Barbosa', 'kivanio@gmail.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove if post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  self.extra_deps         = [
    ['rghost','>= 0.8.7'],
    ['rghost_barcode','>= 0.8'],
    ['parseline','>= 1.0.3']
  ]

  self.summary = 'Gem que permite trabalhar com bloquetos de cobrança para bancos brasileiros.'
  self.description = 'Gem para emissão de bloquetos de cobrança de bancos brasileiros.'
  self.clean_globs |= %w[**/.DS_Store tmp *.log]
  # self.rdoc_pattern = /rb$|rdoc$/
  path = (self.rubyforge_name == self.name) ? self.rubyforge_name : "\#{self.rubyforge_name}/\#{self.name}"
  self.remote_rdoc_dir = File.join(path.gsub(/^#{self.rubyforge_name}\/?/,''), 'rdoc')
  self.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]