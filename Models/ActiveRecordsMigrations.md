# Active Record Migrations

## Visão Geral

As migrações são uma maneira conveniente de alterar o esquema do seu banco de dados ao longo do tempo de maneira consistente. Eles usam uma DSL Ruby para que você não precise escrever SQL manualmente, permitindo que seu esquema e alterações sejam independentes do banco de dados.

Você pode pensar em cada migração como sendo uma nova “versão” do banco de dados. Um esquema começa sem nada e cada migração o modifica para adicionar ou remover tabelas, colunas ou entradas. O Active Record sabe como atualizar seu esquema ao longo dessa linha do tempo, trazendo-o de qualquer ponto do histórico para a versão mais recente. O Active Record também atualizará seu arquivo `db/schema.rb` para corresponder à estrutura atualizada do seu banco de dados.

Aqui está um exemplo de migração:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Esta migração adiciona uma tabela chamada `products` com uma coluna `string` chamada `name` e uma coluna de `texto` chamada `description`. Uma coluna de `chave primária` chamada `id` também será adicionada implicitamente, pois é a chave primária padrão para todos os modelos do Active Record. A macro `timestamps` adiciona duas colunas `created_at` e `updated_at`. Essas colunas especiais são gerenciadas automaticamente pelo Active Record, se existirem.

Observe que definimos a mudança que queremos que aconteça no futuro. Antes desta migração ser executada, não haverá tabela. Depois, a tabela existirá. O Active Record também sabe como reverter essa migração: se revertermos essa migração, ele removerá a tabela.

Em bancos de dados que suportam transações com instruções que alteram o esquema, cada migração é encapsulada em uma transação. Se o banco de dados não suportar isso, quando uma migração falhar, as partes bem-sucedidas não serão revertidas. Você terá que reverter as alterações feitas manualmente.

![Aviso Migrations e DDL](/imagens/aviso_active_record_migration1.JPG)


Se você deseja que uma migração faça algo que o Active Record não sabe como reverter, você pode usar `reversible`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Esta migração alterará o tipo da coluna `price` para uma `string` ou voltará para um número `inteiro` quando a migração for revertida. Observe o bloco sendo passado para `direction.up` e `direction.down` respectivamente.

Alternativamente, você pode usar `up` e `down` em vez de change:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.1]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

## Gerando Migrações

As migrações são armazenadas como arquivos no diretório `db/migrate`, um para cada classe de migração. O nome do arquivo tem o formato `YYYYMMDDHHMMSS_create_products.rb`, ou seja, um carimbo de data/hora UTC que identifica a migração seguido de um sublinhado seguido do nome da migração. O nome da classe de migração (versão CamelCased) deve corresponder à última parte do nome do arquivo. Por exemplo `20080906120000_create_products.rb`, deveria definir classe `CreateProduct` e `20080906120001_add_details_to_products.rb` deveria definir `AddDetailsToProducts`. O Rails usa esse timestamp para determinar qual migração deve ser executada e em que ordem, portanto, se você estiver copiando uma migração de outra aplicação ou gerando um arquivo você mesmo, esteja ciente de sua posição na ordem.

É claro que calcular carimbos de data e hora não é divertido, então o Active Record fornece um gerador para fazer isso para você:

```bash
$ rails generate migration AddPartNumberToProducts
```

Isso criará uma migração vazia com nome apropriado:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
  end
end
```

Este gerador pode fazer muito mais do que acrescentar um carimbo de data/hora ao nome do arquivo. Com base em convenções de nomenclatura e argumentos adicionais (opcionais), ele também pode começar a dar corpo à migração.

Se o nome da migração estiver no formato "AddColumnToTable" ou "RemoveColumnFromTable" e for seguido por uma lista de nomes e tipos de colunas, uma migração contendo as instruções apropriadas `add_column` e `remove_column` será criada.

```bash
$ rails generate migration AddPartNumberToProducts part_number:string
```

Isso irá gerar a seguinte migração:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
  end
end
```

Se quiser adicionar um índice na nova coluna, você também pode fazer isso.

```bash
$ rails generate migration AddPartNumberToProducts part_number:string:index
```

Isso gerará as declarações `add_column` e apropriadas: `add_index`

```Ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

Você não está limitado a uma coluna gerada magicamente. Por exemplo:

```bash
$ rails generate migration AddDetailsToProducts part_number:string price:decimal
```

Irá gerar uma migração de esquema que adiciona duas colunas adicionais à tabela `products`.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

Da mesma forma, você pode gerar uma migração para remover uma coluna da linha de comando:

```bash
$ rails generate migration RemovePartNumberFromProducts part_number:string
```

Isso gera as declarações `remove_column` apropriadas:

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.1]
  def change
    remove_column :products, :part_number, :string
  end
end
```

Se o nome da migração estiver no formato "CreateXXX" e for seguido por uma lista de nomes e tipos de colunas, será gerada uma migração criando a tabela XXX com as colunas listadas. Por exemplo:


```bash
$ rails generate migration CreateProducts name:string part_number:string
```

gera

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
    end
  end
end
```

Como sempre, o que foi gerado para você é apenas um ponto de partida. Você pode adicionar ou remover conforme achar necessário, editando o arquivo `db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`.

Além disso, o gerador aceita o tipo de coluna como references(também disponível como belongs_to). Por exemplo,

```bash
$ rails generate migration AddUserRefToProducts user:references
```

gera a seguinte chamada `add_reference`:

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

Esta migração criará uma colubna `user_id`. As referências são uma forma abreviada de criar colunas, índices, chaves estrangeiras ou até mesmo colunas de associação polimórfica.

Existe também um gerador que produzirá tabelas de junção se fizer `JoinTable` parte do nome:

```bash
$ rails generate migration CreateJoinTableCustomerProduct customer product
```

produzirá a seguinte migração:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.1]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```

Os geradores de modelo, recurso e scaffold criarão migrações apropriadas para adicionar um novo modelo. Esta migração já conterá instruções para a criação da tabela relevante. Se você informar ao Rails quais colunas deseja, instruções para adicionar essas colunas serão criadas. Por exemplo, executando:

```bash
$ rails generate model Product name:string description:text
```

Isso criará uma migração semelhante a esta:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Você pode anexar quantos pares de nome/tipo de coluna desejar

Alguns modificadores de tipo comumente usados ​​podem ser passados ​​diretamente na linha de comando. Eles são colocados entre chaves e seguem o tipo de campo:

Por exemplo, executando:

```bash
$ rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

produzirá uma migração parecida com esta

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```
## Escrevendo Migrações

O método `create_table` é um dos mais fundamentais, mas na maioria das vezes será gerado para você a partir do uso de um modelo, recurso ou gerador de scaffold. Um uso típico seria

```ruby
create_table :products do |t|
  t.string :name
end
```

Este método cria uma tabela `products` com uma coluna chamada `name`.

Por padrão, `create_table` criará implicitamente uma chave primária chamada `id` para você. Você pode alterar o nome da coluna com a opção `:primary_key` ou passar um array `:primary_key` para uma chave primária composta. Se você não deseja nenhuma chave primária, pode passar a opção `id: false`.

Se precisar passar opções específicas do banco de dados, você pode colocar um fragmento SQL na opção `:options`. Por exemplo:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

Isso será anexado `ENGINE=BLACKHOLE` à instrução SQL usada para criar a tabela.

Um índice pode ser criado nas colunas criadas dentro do bloco `create_table` passando `index: true` ou um hash de opções para a opção `:index`:

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

Além disso, você pode passar a opção `:comment` com qualquer descrição para a tabela que será armazenada no próprio banco de dados e poderá ser visualizada com ferramentas de administração de banco de dados, como MySQL Workbench ou PgAdmin III. É altamente recomendável especificar comentários em migrações para aplicações com grandes bancos de dados, pois isso ajuda as pessoas a entender o modelo de dados e a gerar documentação. Atualmente apenas os adaptadores MySQL e PostgreSQL suportam comentários.

Um exemplo prático de como adicionar um comentário a uma tabela em uma migração do Ruby on Rails seria algo assim:

```ruby
class AdicionarComentarioATabelaUsuarios < ActiveRecord::Migration[6.0]
  def change
    create_table :usuarios, comment: 'Esta tabela armazena informações dos usuários do sistema' do |t|
      t.string :nome
      t.string :email
      t.timestamps
    end
  end
end
```

Neste exemplo, ao criar a tabela usuarios, foi passado o parâmetro comment com uma descrição da tabela. Isso irá adicionar um comentário à definição da tabela no banco de dados. Quando você olhar a estrutura da tabela através de ferramentas de administração de banco de dados como MySQL Workbench ou PgAdmin III, você verá esse comentário associado à tabela. Isso pode ajudar outros desenvolvedores a entenderem a finalidade da tabela e sua estrutura.


