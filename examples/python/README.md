# Exemplos Python - BRCobrança API

Este diretório contém exemplos de integração com BRCobrança usando Python, através de uma API REST.

## Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [API REST](#api-rest)
- [Exemplos Sicoob](#exemplos-sicoob)
- [Cliente Python](#cliente-python)
- [Testes](#testes)

---

## Visão Geral

Para usar BRCobrança com Python, você precisa:

1. **API REST em Ruby/Rails** - Servidor que expõe endpoints para gerar boletos
2. **Cliente Python** - Aplicação Python que consome a API

### Arquitetura

```
┌─────────────────┐         HTTP/JSON         ┌─────────────────┐
│                 │ ──────────────────────────> │                 │
│  App Python     │   POST /api/boletos        │  API Rails      │
│  (Cliente)      │                             │  (BRCobrança)   │
│                 │ <────────────────────────── │                 │
└─────────────────┘   PDF/JSON Response        └─────────────────┘
```

---

## Pré-requisitos

### Python

```bash
# Python 3.8+
python3 --version

# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows

# Instalar dependências
pip install requests python-dateutil
```

### API Rails (Servidor)

Veja o arquivo [rails_api_server.rb](rails_api_server.rb) para um exemplo completo de servidor API.

---

## API REST

### Endpoint: Gerar Boleto Sicoob

**POST** `/api/boletos/sicoob`

**Headers:**
```
Content-Type: application/json
Authorization: Bearer <seu_token>
```

**Request Body:**
```json
{
  "cedente": "M&S do Brasil Ltda",
  "documento_cedente": "12345678000190",
  "cedente_endereco": "Rua Exemplo, 123 - São Paulo/SP",
  "sacado": "João da Silva",
  "sacado_documento": "12345678900",
  "sacado_endereco": "Rua Cliente, 456 - Rio de Janeiro/RJ",
  "agencia": "4327",
  "conta_corrente": "417270",
  "convenio": "229385",
  "nosso_numero": "123",
  "variacao": "01",
  "quantidade": "001",
  "carteira": "1",
  "valor": 150.50,
  "data_documento": "2025-11-24",
  "data_vencimento": "2025-12-24",
  "aceite": "N",
  "documento_numero": "NF-001",
  "instrucoes": "Não receber após o vencimento"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "boleto": {
    "banco": "756",
    "agencia_conta": "4327 / 0229385",
    "nosso_numero": "0000123-5",
    "codigo_barras": "75690000001505042710012293850000123501001",
    "linha_digitavel": "75690.00009 01505.042717 00012.293858 0 00001505042",
    "valor": 150.50,
    "vencimento": "2025-12-24"
  },
  "pdf_base64": "JVBERi0xLjQKJeLjz9MKMSAwIG9iago8PC...",
  "pdf_url": "https://exemplo.com/boletos/123.pdf"
}
```

---

## Exemplos Sicoob

### 1. Cliente Python Básico

Arquivo: [sicoob_client.py](sicoob_client.py)

```python
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


def exemplo_basico():
    """Exemplo básico de uso"""

    # Inicializar cliente
    client = SicoobBoletoClient(
        api_url='https://api.exemplo.com',
        api_token='seu_token_aqui'
    )

    # Calcular data de vencimento (30 dias)
    vencimento = (datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')

    try:
        # Gerar boleto
        resultado = client.gerar_boleto(
            # Beneficiário
            cedente='M&S do Brasil Ltda',
            documento_cedente='12345678000190',
            cedente_endereco='Rua Exemplo, 123 - São Paulo/SP',

            # Pagador
            sacado='João da Silva',
            sacado_documento='12345678900',
            sacado_endereco='Rua Cliente, 456 - Rio/RJ',

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

        if resultado['success']:
            boleto = resultado['boleto']
            print(f"✓ Boleto gerado com sucesso!")
            print(f"  Nosso Número: {boleto['nosso_numero']}")
            print(f"  Código de Barras: {boleto['codigo_barras']}")
            print(f"  Linha Digitável: {boleto['linha_digitavel']}")
            print(f"  Valor: R$ {boleto['valor']:.2f}")

            # Salvar PDF
            if 'pdf_base64' in resultado:
                client.salvar_pdf(resultado['pdf_base64'], 'boleto.pdf')
                print(f"  PDF salvo: boleto.pdf")
        else:
            print(f"✗ Erro: {resultado.get('error', 'Erro desconhecido')}")

    except requests.HTTPError as e:
        print(f"✗ Erro HTTP: {e}")
        print(f"  Resposta: {e.response.text}")
    except Exception as e:
        print(f"✗ Erro: {e}")


if __name__ == '__main__':
    exemplo_basico()
```

### 2. Exemplo com Validação

Arquivo: [sicoob_validated.py](sicoob_validated.py)

```python
import re
from typing import Dict, Any
from sicoob_client import SicoobBoletoClient
from datetime import datetime, timedelta


def validar_cpf_cnpj(documento: str) -> bool:
    """Valida CPF ou CNPJ"""
    documento = re.sub(r'\D', '', documento)
    return len(documento) in [11, 14]


def validar_agencia(agencia: str) -> bool:
    """Valida agência (até 4 dígitos)"""
    return len(agencia) <= 4 and agencia.isdigit()


def validar_convenio(convenio: str) -> bool:
    """Valida convênio Sicoob (até 7 dígitos)"""
    return len(convenio) <= 7 and convenio.isdigit()


def validar_nosso_numero(nosso_numero: str) -> bool:
    """Valida nosso número Sicoob (até 7 dígitos)"""
    return len(nosso_numero) <= 7 and nosso_numero.isdigit()


class SicoobBoletoValidado:
    """Cliente com validações"""

    def __init__(self, api_url: str, api_token: str):
        self.client = SicoobBoletoClient(api_url, api_token)

    def gerar_boleto_validado(self, dados: Dict[str, Any]) -> Dict[str, Any]:
        """
        Gera boleto com validações

        Args:
            dados: Dicionário com dados do boleto

        Returns:
            Dict com resultado

        Raises:
            ValueError: Se validação falhar
        """
        # Validar CPF/CNPJ
        if not validar_cpf_cnpj(dados['documento_cedente']):
            raise ValueError('CNPJ do cedente inválido')

        if not validar_cpf_cnpj(dados['sacado_documento']):
            raise ValueError('CPF/CNPJ do sacado inválido')

        # Validar dados bancários
        if not validar_agencia(dados['agencia']):
            raise ValueError('Agência inválida (máx 4 dígitos)')

        if not validar_convenio(dados['convenio']):
            raise ValueError('Convênio inválido (máx 7 dígitos)')

        if not validar_nosso_numero(str(dados['nosso_numero'])):
            raise ValueError('Nosso número inválido (máx 7 dígitos)')

        # Validar valor
        if dados['valor'] <= 0:
            raise ValueError('Valor deve ser maior que zero')

        # Validar data de vencimento
        vencimento = datetime.strptime(dados['data_vencimento'], '%Y-%m-%d')
        if vencimento < datetime.now():
            raise ValueError('Data de vencimento não pode ser no passado')

        # Gerar boleto
        return self.client.gerar_boleto(**dados)


def exemplo_com_validacao():
    """Exemplo com validações"""

    client = SicoobBoletoValidado(
        api_url='https://api.exemplo.com',
        api_token='seu_token_aqui'
    )

    dados_boleto = {
        'cedente': 'M&S do Brasil Ltda',
        'documento_cedente': '12345678000190',
        'sacado': 'Maria Santos',
        'sacado_documento': '98765432100',
        'agencia': '4327',
        'conta_corrente': '417270',
        'convenio': '229385',
        'nosso_numero': '456',
        'valor': 250.00,
        'data_vencimento': (datetime.now() + timedelta(days=15)).strftime('%Y-%m-%d'),
        'documento_numero': 'NF-002'
    }

    try:
        resultado = client.gerar_boleto_validado(dados_boleto)
        print("✓ Boleto gerado com sucesso!")
        print(f"  Linha digitável: {resultado['boleto']['linha_digitavel']}")
    except ValueError as e:
        print(f"✗ Erro de validação: {e}")
    except Exception as e:
        print(f"✗ Erro: {e}")


if __name__ == '__main__':
    exemplo_com_validacao()
```

### 3. Exemplo com Django

Arquivo: [sicoob_django_view.py](sicoob_django_view.py)

```python
"""
Exemplo de integração com Django
"""
from django.http import JsonResponse, HttpResponse
from django.views import View
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from datetime import datetime, timedelta
import json
from sicoob_client import SicoobBoletoClient


@method_decorator(csrf_exempt, name='dispatch')
class GerarBoletoView(View):
    """View Django para gerar boletos"""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.client = SicoobBoletoClient(
            api_url='https://api.exemplo.com',
            api_token='seu_token_aqui'
        )

    def post(self, request):
        """Gera boleto via POST"""
        try:
            dados = json.loads(request.body)

            # Validar dados obrigatórios
            campos_obrigatorios = [
                'cedente', 'documento_cedente',
                'sacado', 'sacado_documento',
                'agencia', 'convenio', 'nosso_numero',
                'valor'
            ]

            for campo in campos_obrigatorios:
                if campo not in dados:
                    return JsonResponse({
                        'success': False,
                        'error': f'Campo obrigatório faltando: {campo}'
                    }, status=400)

            # Data de vencimento padrão: 30 dias
            if 'data_vencimento' not in dados:
                dados['data_vencimento'] = (
                    datetime.now() + timedelta(days=30)
                ).strftime('%Y-%m-%d')

            # Gerar boleto
            resultado = self.client.gerar_boleto(**dados)

            return JsonResponse(resultado)

        except json.JSONDecodeError:
            return JsonResponse({
                'success': False,
                'error': 'JSON inválido'
            }, status=400)
        except Exception as e:
            return JsonResponse({
                'success': False,
                'error': str(e)
            }, status=500)

    def get(self, request):
        """Retorna documentação da API"""
        return JsonResponse({
            'endpoint': '/api/gerar-boleto',
            'method': 'POST',
            'content_type': 'application/json',
            'campos_obrigatorios': [
                'cedente', 'documento_cedente',
                'sacado', 'sacado_documento',
                'agencia', 'convenio', 'nosso_numero',
                'valor'
            ],
            'exemplo': {
                'cedente': 'Empresa Exemplo',
                'documento_cedente': '12345678000190',
                'sacado': 'Cliente Exemplo',
                'sacado_documento': '12345678900',
                'agencia': '4327',
                'conta_corrente': '417270',
                'convenio': '229385',
                'nosso_numero': '123',
                'valor': 100.00
            }
        })


# urls.py
"""
from django.urls import path
from .views import GerarBoletoView

urlpatterns = [
    path('api/gerar-boleto', GerarBoletoView.as_view(), name='gerar-boleto'),
]
"""
```

### 4. Exemplo com Flask

Arquivo: [sicoob_flask_app.py](sicoob_flask_app.py)

```python
"""
Exemplo de integração com Flask
"""
from flask import Flask, request, jsonify, send_file
from datetime import datetime, timedelta
import base64
import io
from sicoob_client import SicoobBoletoClient


app = Flask(__name__)

# Configurar cliente
client = SicoobBoletoClient(
    api_url='https://api.exemplo.com',
    api_token='seu_token_aqui'
)


@app.route('/api/boleto/sicoob', methods=['POST'])
def gerar_boleto():
    """Endpoint para gerar boleto Sicoob"""
    try:
        dados = request.get_json()

        # Validar dados obrigatórios
        campos_obrigatorios = [
            'cedente', 'documento_cedente',
            'sacado', 'sacado_documento',
            'agencia', 'convenio', 'nosso_numero',
            'valor'
        ]

        for campo in campos_obrigatorios:
            if campo not in dados:
                return jsonify({
                    'success': False,
                    'error': f'Campo obrigatório faltando: {campo}'
                }), 400

        # Data de vencimento padrão
        if 'data_vencimento' not in dados:
            dados['data_vencimento'] = (
                datetime.now() + timedelta(days=30)
            ).strftime('%Y-%m-%d')

        # Gerar boleto
        resultado = client.gerar_boleto(**dados)

        return jsonify(resultado)

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/boleto/sicoob/pdf', methods=['POST'])
def gerar_boleto_pdf():
    """Endpoint que retorna PDF diretamente"""
    try:
        dados = request.get_json()

        # Gerar boleto
        resultado = client.gerar_boleto(**dados)

        if not resultado['success']:
            return jsonify(resultado), 400

        # Decodificar PDF
        pdf_bytes = base64.b64decode(resultado['pdf_base64'])

        # Retornar PDF
        return send_file(
            io.BytesIO(pdf_bytes),
            mimetype='application/pdf',
            as_attachment=True,
            download_name=f"boleto_{resultado['boleto']['nosso_numero']}.pdf"
        )

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


@app.route('/api/boleto/sicoob/info', methods=['GET'])
def info():
    """Informações sobre a API"""
    return jsonify({
        'endpoints': {
            'gerar_json': {
                'url': '/api/boleto/sicoob',
                'method': 'POST',
                'response': 'JSON com dados do boleto'
            },
            'gerar_pdf': {
                'url': '/api/boleto/sicoob/pdf',
                'method': 'POST',
                'response': 'PDF do boleto'
            }
        },
        'campos': {
            'obrigatorios': [
                'cedente', 'documento_cedente',
                'sacado', 'sacado_documento',
                'agencia', 'convenio', 'nosso_numero', 'valor'
            ],
            'opcionais': [
                'conta_corrente', 'variacao', 'carteira',
                'data_vencimento', 'documento_numero', 'instrucoes'
            ]
        }
    })


if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

---

## Cliente Python

Para usar os exemplos, você precisa ter uma API REST em Ruby/Rails. Veja o arquivo [rails_api_server.rb](rails_api_server.rb) para um exemplo completo.

### Instalação

```bash
# Clonar repositório
git clone https://github.com/Maxwbh/brcobranca.git
cd brcobranca/examples/python

# Criar ambiente virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

### Uso Básico

```python
from sicoob_client import SicoobBoletoClient
from datetime import datetime, timedelta

# Inicializar
client = SicoobBoletoClient(
    api_url='http://localhost:3000',
    api_token='seu_token'
)

# Gerar boleto
resultado = client.gerar_boleto(
    cedente='Sua Empresa',
    documento_cedente='12345678000190',
    sacado='Cliente',
    sacado_documento='12345678900',
    agencia='4327',
    conta_corrente='417270',
    convenio='229385',
    nosso_numero='123',
    valor=100.00,
    data_vencimento=(datetime.now() + timedelta(days=30)).strftime('%Y-%m-%d')
)

print(resultado['boleto']['linha_digitavel'])
```

---

## Testes

Arquivo: [test_sicoob_client.py](test_sicoob_client.py)

```python
import unittest
from unittest.mock import Mock, patch
from sicoob_client import SicoobBoletoClient
from datetime import datetime, timedelta


class TestSicoobClient(unittest.TestCase):
    """Testes para o cliente Sicoob"""

    def setUp(self):
        self.client = SicoobBoletoClient(
            api_url='https://api.test.com',
            api_token='test_token'
        )

    def test_inicializacao(self):
        """Testa inicialização do cliente"""
        self.assertEqual(self.client.api_url, 'https://api.test.com')
        self.assertEqual(self.client.api_token, 'test_token')
        self.assertIn('Authorization', self.client.headers)

    @patch('sicoob_client.requests.post')
    def test_gerar_boleto_sucesso(self, mock_post):
        """Testa geração de boleto com sucesso"""
        # Mock da resposta
        mock_response = Mock()
        mock_response.json.return_value = {
            'success': True,
            'boleto': {
                'nosso_numero': '0000123-5',
                'codigo_barras': '75690000001505042717',
                'linha_digitavel': '75690.00009 01505.042717'
            }
        }
        mock_post.return_value = mock_response

        # Testar
        resultado = self.client.gerar_boleto(
            cedente='Test',
            documento_cedente='12345678000190',
            sacado='Cliente',
            sacado_documento='12345678900',
            agencia='4327',
            convenio='229385',
            nosso_numero='123',
            valor=100.00,
            data_vencimento='2025-12-31'
        )

        self.assertTrue(resultado['success'])
        self.assertIn('boleto', resultado)

    def test_validacao_campos(self):
        """Testa validação de campos"""
        with self.assertRaises(TypeError):
            self.client.gerar_boleto()


if __name__ == '__main__':
    unittest.main()
```

---

## Dependências

**requirements.txt:**
```
requests>=2.31.0
python-dateutil>=2.8.2
```

---

## Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

---

## Licença

Este código está sob a licença BSD, a mesma do projeto BRCobrança original.

---

## Suporte

- **Issues:** https://github.com/Maxwbh/brcobranca/issues
- **Documentação:** [CAMPOS_BANCOS.md](../../CAMPOS_BANCOS.md)

---

**Mantido por:** Maxwell da Silva Oliveira (@maxwbh) - M&S do Brasil Ltda
