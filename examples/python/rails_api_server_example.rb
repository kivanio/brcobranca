# frozen_string_literal: true

# ============================================================================
# Exemplo de API Rails para BRCobrança
# ============================================================================
#
# Este é um exemplo de como criar uma API REST em Rails para expor
# a funcionalidade do BRCobrança para clientes Python (ou qualquer outra
# linguagem que consuma APIs REST).
#
# Autor: Maxwell da Silva Oliveira (@maxwbh)
# Empresa: M&S do Brasil Ltda
# Licença: BSD
#
# ============================================================================

# app/controllers/api/boletos_controller.rb
module Api
  class BoletosController < ApplicationController
    # Desabilitar CSRF para API
    skip_before_action :verify_authenticity_token

    # Autenticação via token (exemplo simples)
    before_action :authenticate_token!

    # POST /api/boletos/sicoob
    def sicoob
      begin
        # Criar instância do boleto Sicoob
        boleto = Brcobranca::Boleto::Sicoob.new(boleto_params)

        # Validar boleto
        unless boleto.valid?
          return render json: {
            success: false,
            error: 'Boleto inválido',
            errors: boleto.errors.full_messages
          }, status: :unprocessable_entity
        end

        # Gerar PDF
        pdf = boleto.to(:pdf)

        # Montar resposta
        response_data = {
          success: true,
          boleto: {
            banco: boleto.banco,
            banco_dv: boleto.banco_dv,
            agencia_conta: boleto.agencia_conta_boleto,
            nosso_numero: boleto.nosso_numero_boleto,
            codigo_barras: boleto.codigo_barras,
            linha_digitavel: boleto.codigo_barras.linha_digitavel,
            valor: boleto.valor,
            vencimento: boleto.data_vencimento,
            cedente: boleto.cedente,
            sacado: boleto.sacado
          },
          pdf_base64: Base64.strict_encode64(pdf)
        }

        render json: response_data, status: :ok

      rescue StandardError => e
        Rails.logger.error "Erro ao gerar boleto: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")

        render json: {
          success: false,
          error: e.message
        }, status: :internal_server_error
      end
    end

    # POST /api/boletos/sicoob/pdf
    # Retorna PDF diretamente (não JSON)
    def sicoob_pdf
      begin
        boleto = Brcobranca::Boleto::Sicoob.new(boleto_params)

        unless boleto.valid?
          return render json: {
            success: false,
            error: 'Boleto inválido',
            errors: boleto.errors.full_messages
          }, status: :unprocessable_entity
        end

        pdf = boleto.to(:pdf)

        send_data pdf,
                  filename: "boleto_sicoob_#{boleto.nosso_numero}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'

      rescue StandardError => e
        render json: {
          success: false,
          error: e.message
        }, status: :internal_server_error
      end
    end

    # GET /api/boletos/sicoob/info
    def sicoob_info
      render json: {
        banco: 'Sicoob (756)',
        campos_obrigatorios: [
          'cedente',
          'documento_cedente',
          'sacado',
          'sacado_documento',
          'agencia',
          'conta_corrente',
          'convenio',
          'nosso_numero',
          'valor',
          'data_vencimento'
        ],
        campos_opcionais: [
          'cedente_endereco',
          'sacado_endereco',
          'variacao',
          'quantidade',
          'carteira',
          'aceite',
          'data_documento',
          'documento_numero',
          'instrucoes'
        ],
        validacoes: {
          agencia: 'máximo 4 dígitos',
          conta_corrente: 'máximo 8 dígitos',
          convenio: 'máximo 7 dígitos',
          nosso_numero: 'máximo 7 dígitos',
          variacao: 'máximo 2 dígitos',
          quantidade: 'máximo 3 dígitos'
        },
        exemplo: {
          cedente: 'M&S do Brasil Ltda',
          documento_cedente: '12345678000190',
          sacado: 'João da Silva',
          sacado_documento: '12345678900',
          agencia: '4327',
          conta_corrente: '417270',
          convenio: '229385',
          nosso_numero: '123',
          variacao: '01',
          quantidade: '001',
          carteira: '1',
          valor: 150.50,
          data_documento: '2025-11-24',
          data_vencimento: '2025-12-24',
          aceite: 'N',
          documento_numero: 'NF-001',
          instrucoes: 'Não receber após o vencimento'
        }
      }
    end

    private

    def authenticate_token!
      # Exemplo simples de autenticação via Bearer token
      token = request.headers['Authorization']&.gsub('Bearer ', '')

      unless valid_token?(token)
        render json: {
          success: false,
          error: 'Token inválido ou não fornecido'
        }, status: :unauthorized
      end
    end

    def valid_token?(token)
      # ALTERE PARA SUA LÓGICA DE VALIDAÇÃO
      # Exemplo: verificar no banco de dados, JWT, etc.
      return false if token.blank?

      # Exemplo simples (NÃO USE EM PRODUÇÃO)
      expected_token = ENV['API_TOKEN'] || 'seu_token_aqui'
      token == expected_token
    end

    def boleto_params
      # Permitir todos os parâmetros necessários
      params.permit(
        :cedente,
        :documento_cedente,
        :cedente_endereco,
        :sacado,
        :sacado_documento,
        :sacado_endereco,
        :agencia,
        :conta_corrente,
        :convenio,
        :nosso_numero,
        :variacao,
        :quantidade,
        :carteira,
        :valor,
        :data_documento,
        :data_vencimento,
        :aceite,
        :documento_numero,
        :instrucoes
      )
    end
  end
end

# ============================================================================
# config/routes.rb
# ============================================================================
#
# Rails.application.routes.draw do
#   namespace :api do
#     # Sicoob
#     post 'boletos/sicoob', to: 'boletos#sicoob'
#     post 'boletos/sicoob/pdf', to: 'boletos#sicoob_pdf'
#     get 'boletos/sicoob/info', to: 'boletos#sicoob_info'
#
#     # Outros bancos (adicionar conforme necessário)
#     # post 'boletos/itau', to: 'boletos#itau'
#     # post 'boletos/bradesco', to: 'boletos#bradesco'
#   end
# end

# ============================================================================
# Gemfile
# ============================================================================
#
# gem 'brcobranca'
# gem 'rack-cors' # Para permitir CORS se necessário

# ============================================================================
# config/initializers/cors.rb (opcional)
# ============================================================================
#
# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins '*' # Em produção, especifique os domínios permitidos
#
#     resource '/api/*',
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

# ============================================================================
# config/initializers/brcobranca.rb
# ============================================================================
#
# Brcobranca.setup do |config|
#   config.gerador = :prawn # Mais leve que :rghost
# end

# ============================================================================
# EXEMPLO DE USO COM CURL
# ============================================================================
#
# # Gerar boleto (retorna JSON)
# curl -X POST http://localhost:3000/api/boletos/sicoob \
#   -H "Content-Type: application/json" \
#   -H "Authorization: Bearer seu_token_aqui" \
#   -d '{
#     "cedente": "M&S do Brasil Ltda",
#     "documento_cedente": "12345678000190",
#     "sacado": "João da Silva",
#     "sacado_documento": "12345678900",
#     "agencia": "4327",
#     "conta_corrente": "417270",
#     "convenio": "229385",
#     "nosso_numero": "123",
#     "valor": 150.50,
#     "data_vencimento": "2025-12-31"
#   }'
#
# # Gerar boleto (retorna PDF)
# curl -X POST http://localhost:3000/api/boletos/sicoob/pdf \
#   -H "Content-Type: application/json" \
#   -H "Authorization: Bearer seu_token_aqui" \
#   -d '{ ... }' \
#   --output boleto.pdf
#
# # Obter informações
# curl http://localhost:3000/api/boletos/sicoob/info \
#   -H "Authorization: Bearer seu_token_aqui"

# ============================================================================
# TESTES (RSpec)
# ============================================================================
#
# # spec/requests/api/boletos_spec.rb
# require 'rails_helper'
#
# RSpec.describe 'Api::Boletos', type: :request do
#   let(:valid_token) { 'seu_token_aqui' }
#   let(:headers) do
#     {
#       'Content-Type' => 'application/json',
#       'Authorization' => "Bearer #{valid_token}"
#     }
#   end
#
#   let(:valid_params) do
#     {
#       cedente: 'M&S do Brasil Ltda',
#       documento_cedente: '12345678000190',
#       sacado: 'João da Silva',
#       sacado_documento: '12345678900',
#       agencia: '4327',
#       conta_corrente: '417270',
#       convenio: '229385',
#       nosso_numero: '123',
#       valor: 150.50,
#       data_vencimento: '2025-12-31'
#     }
#   end
#
#   describe 'POST /api/boletos/sicoob' do
#     context 'com parâmetros válidos' do
#       it 'gera o boleto com sucesso' do
#         post '/api/boletos/sicoob', params: valid_params.to_json, headers: headers
#
#         expect(response).to have_http_status(:ok)
#         json = JSON.parse(response.body)
#         expect(json['success']).to be true
#         expect(json['boleto']).to be_present
#         expect(json['boleto']['codigo_barras']).to be_present
#       end
#     end
#
#     context 'sem token' do
#       it 'retorna unauthorized' do
#         post '/api/boletos/sicoob', params: valid_params.to_json,
#           headers: { 'Content-Type' => 'application/json' }
#
#         expect(response).to have_http_status(:unauthorized)
#       end
#     end
#
#     context 'com parâmetros inválidos' do
#       it 'retorna erro de validação' do
#         invalid_params = valid_params.merge(valor: -10)
#         post '/api/boletos/sicoob', params: invalid_params.to_json, headers: headers
#
#         expect(response).to have_http_status(:unprocessable_entity)
#       end
#     end
#   end
# end
