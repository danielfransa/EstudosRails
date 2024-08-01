require_relative "display/menu"
require_relative "display/operacoes_de_tela"
require_relative "core/cadastrar_produto"
require_relative "core/listar_produtos"
require_relative "core/retirar_estoque"


produtos = [
  {
    id: Time.now.to_i,
    nome: "Maça",
    descricao: "Maça da Turma da Mônica",
    preco: 2.50,
    quantidade: 20
  },
  {
    id: Time.now.to_i + 1,
    nome: "Banana",
    descricao: "Nanica",
    preco: 1.50,
    quantidade: 30
  },
  {
    id: Time.now.to_i + 2,
    nome: "Banana",
    descricao: "Prata",
    preco: 1.99,
    quantidade: 20
  }
]
iniciar_menu(produtos)