# frozen_string_literal: true

module RemessaHelpers
  def read_remessa(name, body = nil)
    filename = File.join(File.dirname(__FILE__), '..', 'fixtures', 'remessa', name)
    File.write(filename, body) unless File.exist?(filename)
    File.read(filename)
  end
end

RSpec.configure do |config|
  config.include RemessaHelpers
end
