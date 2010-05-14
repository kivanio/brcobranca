$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'brcobranca'
require 'spec'
require 'spec/autorun'
require 'tempfile'

Spec::Runner.configure do |config|

end