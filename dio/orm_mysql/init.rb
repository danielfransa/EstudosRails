require_relative "infra/db"
require_relative "models/cliente"
require_relative "models/fornecedor"
require 'terminal-table'


# dados = Infra::Db.new.execute("SELECT * FROM fornecedores")

# puts dados.inspect

# cliente = Models::Cliente.new

# clientes = Models::Cliente.todos

# # clientes.each do |cliente|
# #   puts cliente.nome
# # end

# rows = clientes.map do |cliente|
#     [cliente.id, cliente.nome, cliente.telefone, cliente.cpf]
# end

# table = Terminal::Table.new(
#     :headings => ['ID', 'Nome', 'Telefone', 'CPF'],
#     :rows => rows
# )

# puts table

# fornecedores = Models::Fornecedor.todos

# rows = fornecedores.map do |fornecedor|
#   [fornecedor.id, fornecedor.nome, fornecedor.telefone, fornecedor.cnpj, fornecedor.endereco]
# end

# table = Terminal::Table.new(
#   :headings => ['ID', 'Nome', 'Telefone', 'CNPJ', 'Endereço'],
#   :rows => rows
# )

# puts table

# cliente = Models::Cliente.new
# cliente.nome = "Cliente Teste - #{Time.now.to_i}"
# cliente.telefone = "(12) 3456-7890"
# cliente.cpf = Time.now.to_i

# cliente.incluir

# clientes = Models::Cliente.todos

# rows = clientes.map do |cliente|
#     [cliente.id, cliente.nome, cliente.telefone, cliente.cpf]
# end

# table = Terminal::Table.new(
#     :headings => ['ID', 'Nome', 'Telefone', 'CPF'],
#     :rows => rows
# )

# puts table

fornecedor = Models::Fornecedor.new
fornecedor.nome = "Empresa Teste - #{Time.now.to_i}"
fornecedor.telefone = "(11)1111-1111"
fornecedor.cnpj = Time.now.to_i
fornecedor.endereco = "Rua #{Time.now.to_i} - Araras - SP"
fornecedor.incluir

fornecedores = Models::Fornecedor.todos

rows = fornecedores.map do |fornecedor|
    [fornecedor.id, fornecedor.nome, fornecedor.telefone, fornecedor.cnpj, fornecedor.endereco]
end

table = Terminal::Table.new(
    :headings => ['ID', 'Nome', 'Telefone', 'CNPJ', 'Endereço'], 
    :rows => rows
)

puts table