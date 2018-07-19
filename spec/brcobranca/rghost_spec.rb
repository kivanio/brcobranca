# -*- encoding: utf-8 -*-
#
require 'spec_helper'

RSpec.describe 'RGhost' do
  before do
    @valid_attributes = {
      valor: 0.0,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '4042',
      conta_corrente: '61900',
      convenio: 12_387_989,
      nosso_numero: '777700168'
    }
  end

  it 'Testar se RGhost e GhostScript estão instalados' do
    # RGhost::Config.config_platform
    expect(File.exist?(RGhost::Config::GS[:path])).to be_truthy
    expect(File.executable?(RGhost::Config::GS[:path])).to be_truthy
    s = `#{RGhost::Config::GS[:path]} -v`
    expect(s).to match(/^GPL Ghostscript/)
    s = `#{RGhost::Config::GS[:path]} --version`
    expect(s).to match(/[8-9]\.[0-9]/)
  end
end
