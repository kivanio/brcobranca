
#
module RemessaHelpers
  def read_remessa(name, body = nil)
    filename = File.join(File.dirname(__FILE__), '..', 'fixtures', 'remessa', name)
    File.open(filename, 'w') { |f| f.write(body) } unless File.exist?(filename)
    File.read(filename)
  end
end

RSpec.configure do |config|
  config.include RemessaHelpers
end
