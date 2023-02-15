# frozen_string_literal: true

shared_examples_for 'senha_pdf' do
  it 'aplica senha no pdf do boleto' do
    @valid_attributes[:senha] = '12345'
    boleto_novo = described_class.new(@valid_attributes)
    file_body = boleto_novo.to('pdf').encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    expect(file_body).to match('/Filter /Standard')
    expect(file_body).to match('/Length 128')
  end
end
