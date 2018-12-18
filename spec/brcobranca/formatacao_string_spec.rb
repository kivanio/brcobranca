# -*- encoding: utf-8 -*-
#
require 'spec_helper'

RSpec.describe Brcobranca::FormatacaoString do
  context 'no arguments' do
    it { expect { ''.format_size }.to raise_error(ArgumentError) }
  end

  context 'blank' do
    it { expect(' '.format_size(10)).to eq('          ') }
    it { expect(''.format_size(10)).to eq('          ') }
  end

  context 'above size' do
    it { expect("SOÇIEDADE,  BRASI@?!+-_LEIR'\"A DE ZÔÔLOGIA LTDA.".format_size(30)).to eql('SOCIEDADE BRASILEIRA DE ZOOLOG') }
    it { expect('pablo diego JOSÉ FRANCISCO DE PAULA JUAN'.format_size(30)).to eql('pablo diego JOSE FRANCISCO DE ') }
    it { expect('DF 250, KM 4 Cond. La Foret , Qd. M Casa 03'.format_size(40)).to eql('DF 250 KM 4 Cond La Foret  Qd M Casa 03 ') }
  end

  context 'bellow size' do
    it { expect('SOCIEDADE'.format_size(30)).to eql('SOCIEDADE                     ') }
    it { expect('caçaróla'.format_size(30)).to eql('cacarola                      ') }
  end
end
