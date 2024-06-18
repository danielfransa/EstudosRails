require 'terminal-table'

def retirar_estoque(produtos)
  limpar_tela

  mensagem_amarelo("======= Escolha um dos produtos abaixo: =======", false, false)

  table = Terminal::Table.new do |t|
    t.headings = ['Id', 'Nome', 'Quantidade']
    produtos.each do |row|
      t.add_row [row[:id], row[:nome], row[:quantidade]]
    end
  end
  puts table

  mensagem_azul("Digite o ID fo produto:", false, false)
  id = gets.to_i

  produto = produtos.find{|p| p[:id] == id}
  unless produto
    limpar_tela
    mensagem_vermelho("Produto do ID (#{id}) não encontrado na lista", false, false)
    mensagem_amarelo("Deseja digitar o número novamente? (s/n)", false, false)
    opcao = gets.chomp.downcase
    limpar_tela
    if opcao == "s" || opcao == "sim"
      retirar_estoque(produtos)
    end

    return
  end

  limpar_tela
  mensagem_azul("Digite a quantidade que deseja retirar do estoque do produto: #{amarelo(produto[:nome])}", false, false)
  mensagem_azul("Quantidade atual: #{amarelo(produto[:quantidade])}", false, false)
  quantidade_retirada = gets.to_i
  if produto[:quantidade] < quantidade_retirada
    quantidade_excedida = quantidade_retirada - produto[:quantidade]
    mensagem_vermelho("A quantidade solicitada excede o estoque em #{quantidade_excedida}", true, true, 8)
    quantidade_retirada = ''
    retirar_estoque(produtos)
  else
    produto[:quantidade] = produto[:quantidade] - quantidade_retirada
    mensagem_verde("Retirada realizada com sucesso!", true, true, 3)
    listar_produtos(produtos)
  end
end