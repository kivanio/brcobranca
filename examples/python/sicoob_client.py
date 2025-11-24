#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Cliente Python para gerar boletos Sicoob via API BRCobrança

Autor: Maxwell da Silva Oliveira (@maxwbh)
Empresa: M&S do Brasil Ltda
Licença: BSD
"""

import requests
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
import base64


class SicoobBoletoClient:
    """Cliente Python para gerar boletos Sicoob via API BRCobrança"""

    def __init__(self, api_url: str, api_token: Optional[str] = None):
        """
        Inicializa o cliente

        Args:
            api_url: URL base da API (ex: https://api.exemplo.com)
            api_token: Token de autenticação (opcional)
        """
        self.api_url = api_url.rstrip('/')
        self.api_token = api_token
        self.headers = {'Content-Type': 'application/json'}

        if api_token:
            self.headers['Authorization'] = f'Bearer {api_token}'

    def gerar_boleto(
        self,
        # Dados do beneficiário
        cedente: str,
        documento_cedente: str,
        # Dados do pagador
        sacado: str,
        sacado_documento: str,
        # Dados bancários
        agencia: str,
        conta_corrente: str,
        convenio: str,
        nosso_numero: str,
        # Dados do boleto
        valor: float,
        data_vencimento: str,
        # Opcionais
        cedente_endereco: Optional[str] = None,
        sacado_endereco: Optional[str] = None,
        variacao: str = "01",
        quantidade: str = "001",
        carteira: str = "1",
        aceite: str = "N",
        data_documento: Optional[str] = None,
        documento_numero: Optional[str] = None,
        instrucoes: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Gera um boleto Sicoob

        Args:
            cedente: Nome do beneficiário
            documento_cedente: CNPJ do beneficiário
            sacado: Nome do pagador
            sacado_documento: CPF/CNPJ do pagador
            agencia: Agência (até 4 dígitos)
            conta_corrente: Conta corrente (até 8 dígitos)
            convenio: Convênio/código do cedente (até 7 dígitos)
            nosso_numero: Nosso número (até 7 dígitos)
            valor: Valor do boleto
            data_vencimento: Data de vencimento (formato: YYYY-MM-DD)
            cedente_endereco: Endereço do beneficiário (opcional)
            sacado_endereco: Endereço do pagador (opcional)
            variacao: Variação da carteira (padrão: "01")
            quantidade: Número da parcela (padrão: "001")
            carteira: Carteira (padrão: "1")
            aceite: Aceite (padrão: "N")
            data_documento: Data do documento (opcional, padrão: hoje)
            documento_numero: Número do documento (opcional)
            instrucoes: Instruções para o caixa (opcional)

        Returns:
            Dict contendo dados do boleto gerado

        Raises:
            requests.HTTPError: Se houver erro na requisição
        """
        if data_documento is None:
            data_documento = datetime.now().strftime('%Y-%m-%d')

        payload = {
            'cedente': cedente,
            'documento_cedente': documento_cedente,
            'cedente_endereco': cedente_endereco,
            'sacado': sacado,
            'sacado_documento': sacado_documento,
            'sacado_endereco': sacado_endereco,
            'agencia': agencia,
            'conta_corrente': conta_corrente,
            'convenio': convenio,
            'nosso_numero': str(nosso_numero),
            'variacao': variacao,
            'quantidade': quantidade,
            'carteira': carteira,
            'valor': valor,
            'data_documento': data_documento,
            'data_vencimento': data_vencimento,
            'aceite': aceite,
            'documento_numero': documento_numero,
            'instrucoes': instrucoes
        }

        # Remover valores None
        payload = {k: v for k, v in payload.items() if v is not None}

        response = requests.post(
            f'{self.api_url}/api/boletos/sicoob',
            json=payload,
            headers=self.headers,
            timeout=30
        )

        response.raise_for_status()
        return response.json()

    def salvar_pdf(self, pdf_base64: str, caminho: str) -> None:
        """
        Salva PDF a partir de string base64

        Args:
            pdf_base64: String base64 do PDF
            caminho: Caminho onde salvar o arquivo
        """
        pdf_bytes = base64.b64decode(pdf_base64)
        with open(caminho, 'wb') as f:
            f.write(pdf_bytes)
        print(f"✓ PDF salvo em: {caminho}")


def exemplo_basico():
    """Exemplo básico de uso"""

    # Inicializar cliente
    # ALTERE PARA SUA URL E TOKEN
    client = SicoobBoletoClient(
        api_url='http://localhost:3000',  # URL da sua API Rails
        api_token='seu_token_aqui'        # Seu token de autenticação
    )

    # Calcular data de vencimento (30 dias)
    vencimento = (datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')

    try:
        # Gerar boleto
        print("Gerando boleto Sicoob...")
        resultado = client.gerar_boleto(
            # Beneficiário
            cedente='M&S do Brasil Ltda',
            documento_cedente='12345678000190',
            cedente_endereco='Rua Exemplo, 123 - São Paulo/SP',

            # Pagador
            sacado='João da Silva',
            sacado_documento='12345678900',
            sacado_endereco='Rua Cliente, 456 - Rio de Janeiro/RJ',

            # Dados bancários Sicoob
            agencia='4327',
            conta_corrente='417270',
            convenio='229385',
            nosso_numero='123',

            # Boleto
            valor=150.50,
            data_vencimento=vencimento,
            documento_numero='NF-001',
            instrucoes='Não receber após o vencimento'
        )

        if resultado.get('success'):
            boleto = resultado['boleto']
            print("\n" + "="*60)
            print("✓ BOLETO GERADO COM SUCESSO!")
            print("="*60)
            print(f"Banco: Sicoob ({boleto['banco']})")
            print(f"Agência/Conta: {boleto['agencia_conta']}")
            print(f"Nosso Número: {boleto['nosso_numero']}")
            print(f"Valor: R$ {boleto['valor']:.2f}")
            print(f"Vencimento: {boleto['vencimento']}")
            print(f"\nCódigo de Barras:\n{boleto['codigo_barras']}")
            print(f"\nLinha Digitável:\n{boleto['linha_digitavel']}")
            print("="*60)

            # Salvar PDF se disponível
            if 'pdf_base64' in resultado:
                client.salvar_pdf(resultado['pdf_base64'], 'boleto_sicoob.pdf')
        else:
            print(f"\n✗ ERRO: {resultado.get('error', 'Erro desconhecido')}")

    except requests.HTTPError as e:
        print(f"\n✗ ERRO HTTP: {e}")
        if hasattr(e, 'response'):
            print(f"Resposta do servidor: {e.response.text}")
    except Exception as e:
        print(f"\n✗ ERRO: {e}")


if __name__ == '__main__':
    exemplo_basico()
