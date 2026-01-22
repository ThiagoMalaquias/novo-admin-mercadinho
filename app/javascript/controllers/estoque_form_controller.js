import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "produtoSelect",
    "validade",
    "quantidade",
    "valorUnitario",
    "valorTotal",
    "codigoBarras",
    "tabelaBody",
    "tabelaProdutos",
    "mensagemNenhumItem",
    "form"
  ]

  connect() {
    this.setupEventListeners()
  }

  setupEventListeners() {
    // Prevenir submissão do formulário ao pressionar Enter
    if (this.hasFormTarget) {
      this.formTarget.addEventListener('keydown', (event) => {
        if (
          event.key === 'Enter' &&
          event.target.tagName !== 'BUTTON' &&
          event.target.type !== 'submit' &&
          event.target.id !== 'codigo_barras'
        ) {
          event.preventDefault()
        }
      })
    }
  }

  // Atualiza o valor total quando quantidade ou valor unitário mudam
  atualizarValorTotal() {
    if (!this.hasQuantidadeTarget || !this.hasValorUnitarioTarget || !this.hasValorTotalTarget) return

    const qtd = parseFloat(this.quantidadeTarget.value.replace(",", ".")) || 0
    const valorUnitarioStr = this.valorUnitarioTarget.value.replace(/\./g, '').replace(",", ".")
    const valorUnitario = parseFloat(valorUnitarioStr) || 0

    if (qtd > 0 && valorUnitario > 0) {
      const valorTotal = (qtd * valorUnitario).toFixed(2).replace(".", ",")
      this.valorTotalTarget.value = valorTotal
    } else {
      this.valorTotalTarget.value = ""
    }
  }

  // Busca produto por código de barras ao pressionar Enter
  buscarPorCodigoBarras(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      const codigoBarras = this.codigoBarrasTarget.value
      if (codigoBarras.length > 0) {
        this.buscarProduto(codigoBarras)
      }
    }
  }

  // Busca dados do produto quando o select muda
  buscarDados() {
    if (!this.hasProdutoSelectTarget) return

    const produtoId = this.produtoSelectTarget.value
    if (!produtoId) return

    fetch(`/produtos/${produtoId}.json`, {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
      }
    })
      .then(response => response.json())
      .then(data => {
        this.atualizarCampos(data)
      })
      .catch(error => {
        alert('Produto não encontrado')
        console.error('Erro ao buscar dados do produto:', error)
      })
  }

  // Busca produto por código de barras
  buscarProduto(codigoBarras) {
    fetch(`/produtos/por_codigo_barras.json?codigo_barras=${codigoBarras}`, {
      method: 'GET'
    })
      .then(response => {
        if (!response.ok) {
          throw new Error('Produto não encontrado')
        }
        return response.json()
      })
      .then(data => {
        if (data.id) {
          this.atualizarCampos(data)
        }
      })
      .catch(error => {
        alert('Produto não encontrado')
        console.error('Erro:', error)
      })
  }

  // Atualiza os campos do formulário com os dados do produto
  atualizarCampos(data) {
    if (this.hasValorUnitarioTarget) {
      this.valorUnitarioTarget.value = (data.preco / 100.0).toFixed(2).replace(".", ",") || ''
    }
    if (this.hasProdutoSelectTarget) {
      this.produtoSelectTarget.value = data.id || ''
    }
    if (this.hasCodigoBarrasTarget) {
      this.codigoBarrasTarget.value = data.codigo_venda || ''
    }
    if (this.hasValidadeTarget) {
      this.validadeTarget.value = ''
    }
    if (this.hasQuantidadeTarget) {
      this.quantidadeTarget.value = ''
    }
    if (this.hasValorTotalTarget) {
      this.valorTotalTarget.value = ''
    }

    // Atualizar valor total se houver quantidade
    if (this.hasQuantidadeTarget && this.quantidadeTarget.value) {
      this.atualizarValorTotal()
    }
  }

  // Adiciona um produto à tabela
  adicionarProduto() {
    if (!this.hasProdutoSelectTarget || !this.hasTabelaBodyTarget) return

    const produtoId = this.produtoSelectTarget.value
    const produtoText = this.produtoSelectTarget.options[this.produtoSelectTarget.selectedIndex].text
    const validade = this.hasValidadeTarget ? this.validadeTarget.value : ''
    const quantidade = this.hasQuantidadeTarget ? this.quantidadeTarget.value : ''
    const valorUnitario = this.hasValorUnitarioTarget ? this.valorUnitarioTarget.value : ''
    const valorTotal = this.hasValorTotalTarget ? this.valorTotalTarget.value : ''

    if (this.camposInvalidos(produtoId, quantidade, valorUnitario)) {
      alert('Adicione todos os campos obrigatórios')
      return
    }

    if (this.produtoAdicionado(produtoId)) {
      alert('Produto já adicionado.')
      return
    }

    const novaLinha = document.createElement('tr')
    novaLinha.className = 'hover:bg-gray-50 dark:hover:bg-gray-700/50'

    novaLinha.innerHTML = `
      <td class="px-6 py-4 whitespace-nowrap">
        <input class="w-20 px-2 py-1 border border-gray-300 dark:border-gray-600 rounded bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white text-sm" type="number" name="estoque[produto][][id]" value="${produtoId}" readonly>
      </td>
      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">${produtoText}</td>
      <td class="px-6 py-4 whitespace-nowrap">
        <input class="w-32 px-2 py-1 border border-gray-300 dark:border-gray-600 rounded bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white text-sm" type="date" name="estoque[produto][][validade]" value="${validade}" readonly>
      </td>
      <td class="px-6 py-4 whitespace-nowrap">
        <input class="w-20 px-2 py-1 border border-gray-300 dark:border-gray-600 rounded bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white text-sm" type="number" name="estoque[produto][][quantidade]" value="${quantidade}" readonly>
      </td>
      <td class="px-6 py-4 whitespace-nowrap">
        <input class="w-24 px-2 py-1 border border-gray-300 dark:border-gray-600 rounded bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white text-sm" type="text" name="estoque[produto][][valor_unitario]" value="${valorUnitario}" readonly>
      </td>
      <td class="px-6 py-4 whitespace-nowrap">
        <input class="w-24 px-2 py-1 border border-gray-300 dark:border-gray-600 rounded bg-gray-50 dark:bg-gray-700 text-gray-900 dark:text-white text-sm" type="text" name="estoque[produto][][valor_total]" value="${valorTotal}" readonly>
      </td>
      <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
        <button type="button" data-action="click->estoque-form#removerProduto" class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300 px-3 py-1 rounded hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors">
          <svg class="w-5 h-5 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </td>
    `

    this.tabelaBodyTarget.appendChild(novaLinha)
    this.visualizarTabelaProdutos()
    this.limparCampos()
  }

  // Remove um produto da tabela
  removerProduto(event) {
    const linha = event.currentTarget.closest('tr')
    linha.remove()
    this.visualizarTabelaProdutos()
  }

  // Verifica se um produto já foi adicionado
  produtoAdicionado(produtoId) {
    if (!this.hasTabelaBodyTarget) return false

    const linhas = this.tabelaBodyTarget.getElementsByTagName('tr')
    for (let i = 0; i < linhas.length; i++) {
      const cols = linhas[i].getElementsByTagName('td')
      if (cols.length > 0) {
        const input = cols[0].querySelector('input')
        if (input && input.value === produtoId) {
          return true
        }
      }
    }
    return false
  }

  // Valida se os campos obrigatórios estão preenchidos
  camposInvalidos(produtoId, quantidade, valorUnitario) {
    if (!produtoId || produtoId.length == 0) {
      return true
    }

    if (!quantidade || quantidade.length == 0) {
      return true
    }

    if (!valorUnitario || valorUnitario.length == 0) {
      return true
    }

    return false
  }

  // Mostra ou esconde a tabela de produtos
  visualizarTabelaProdutos() {
    if (!this.hasTabelaBodyTarget || !this.hasTabelaProdutosTarget || !this.hasMensagemNenhumItemTarget) return

    if (this.tabelaBodyTarget.getElementsByTagName('tr').length === 0) {
      this.tabelaProdutosTarget.style.display = 'none'
      this.mensagemNenhumItemTarget.style.display = 'block'
    } else {
      this.tabelaProdutosTarget.style.display = 'block'
      this.mensagemNenhumItemTarget.style.display = 'none'
    }
  }

  // Limpa os campos do formulário após adicionar produto
  limparCampos() {
    if (this.hasProdutoSelectTarget) {
      this.produtoSelectTarget.value = ''
      this.produtoSelectTarget.disabled = false
    }
    if (this.hasValidadeTarget) {
      this.validadeTarget.value = ''
    }
    if (this.hasQuantidadeTarget) {
      this.quantidadeTarget.value = ''
    }
    if (this.hasValorUnitarioTarget) {
      this.valorUnitarioTarget.value = ''
    }
    if (this.hasValorTotalTarget) {
      this.valorTotalTarget.value = ''
    }
    if (this.hasCodigoBarrasTarget) {
      this.codigoBarrasTarget.value = ''
    }
  }
}