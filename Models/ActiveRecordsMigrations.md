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


O método de migração `create_join_table` cria uma tabela de junção HABTM (has and belongs to many - tem e pertence a muitas). Um uso típico seria:

```bash
create_join_table :products, :categories
```

Esta migração criará uma tabela `categories_products` com duas colunas chamadas `category_id` e `product_id`.

Essas colunas têm a opção `:null` definida `false` como padrão, o que significa que você deve fornecer um valor para salvar um registro nesta tabela. Isso pode ser substituído especificando a opção `:column_options`:

```bash
create_join_table :products, :categories, column_options: { null: true }
```

Por padrão, o nome da tabela de junção vem da união dos dois primeiros argumentos fornecidos para create_join_table, em ordem alfabética.

Para personalizar o nome da tabela, forneça uma opção `:table_name`:

```bash
create_join_table :products, :categories, table_name: :categorization
```

Isso garante que o nome da tabela de junção seja `categorization` como solicitado.

Além disso, `create_join_table` aceita um bloco, que você pode usar para adicionar índices (que não são criados por padrão) ou quaisquer colunas adicionais que você escolher.

Se você quiser alterar uma tabela existente, existe o `change_table`.

É usado de maneira semelhante, `create_table` mas o objeto gerado dentro do bloco tem acesso a uma série de funções especiais, por exemplo:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

Esta migração removerá as colunas `description` e `name`, criará uma nova coluna de string chamada `part_number` e adicionará um índice a ela. Finalmente, ele renomeia a coluna `upccode` para `upc_code`.

Semelhante aos métodos `remove_column` e `add_column` que abordamos anteriormente , o Rails também fornece o método `change_column` de migração.

```bash
change_column :products, :part_number, :text
```

Isso altera a coluna `part_number` da tabela de produtos para um campo  `:text`.

Além do `change_column`, os métodos `change_column_null` e `change_column_default` são usados ​​especificamente para alterar uma restrição nula e valores padrão de uma coluna.

```bash
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

Isso define `:name` o campo dos produtos como uma coluna `NOT NULL` e o valor padrão do compo `:approved` de verdadeiro para falso. Ambas as alterações serão aplicadas apenas a transações futuras; quaisquer registros existentes não se aplicam.

Ao definir a restrição nula como verdadeira, isso significa que a coluna aceitará um valor nulo, caso contrário a restrição `NOT NULL` será aplicada e um valor deverá ser passado para persistir o registro no banco de dados.


Os modificadores de coluna podem ser aplicados ao criar ou alterar uma coluna:

*`comment`* Adiciona um comentário para a coluna.

*`collation`* Especifica o agrupamento de uma coluna `string` ou `text`.

*`default`* Permite definir um valor padrão na coluna. Observe que se você estiver usando um valor dinâmico (como uma data), o padrão só será calculado na primeira vez (ou seja, na data em que a migração for aplicada). Usar `nil` para `NULL`.

*`limit Define`* o número máximo de caracteres para uma coluna `string` e o número máximo de bytes para colunas `text/binary/integer`.

*`null`* Permite ou não valores `NULL` na coluna.

*`precision*` Especifica a precisão das colunas `decimal/numeric/datetime/time`.

*`scale`* Especifica a escala das colunas `decimal` e `numeric`, representando o número de dígitos após o ponto `decimal`.

![Aviso sobre index](/imagens/aviso_acitive_record_migration2.JPG)

Alguns adaptadores podem suportar opções adicionais; consulte a documentação da API específica do adaptador para obter mais informações.

![Aviso sobre null e default](/imagens/aviso_acitive_record_migration3.JPG)


O método `add_reference` permite a criação de uma coluna com nome apropriado atuando como conexão entre uma ou mais associações.

```bash
add_reference :users, :role
```

Esta migração criará uma coluna `role_id` na tabela de `usuários`. Ele também cria um índice para esta coluna, a menos que seja explicitamente informado com a opção `index: false`.

O método `add_belongs_to` é um alias de `add_reference`.

```bash
add_belongs_to :taggings, :taggable, polymorphic: true
```

A opção polimórfica criará duas colunas na tabela de tags que podem ser usadas para associações polimórficas: `taggable_type` e `taggable_id`.

Uma chave estrangeira pode ser criada com a opção `foreign_key`.

```bash
add_reference :users, :role, foreign_key: true
```

As referências também podem ser removidas:

```bash
remove_reference :products, :user, foreign_key: true, index: false
```

Embora não seja obrigatório, você pode querer adicionar restrições de chave estrangeira para garantir a integridade referencial.

```bash
add_foreign_key :articles, :authors
```

Esta chamada `add_foreign_key` adiciona uma nova restrição à tabela `articles`. A restrição garante que exista uma linha na tabela `authors` onde a coluna `id`a corresponda ao `articles.author_id`.

Se o nome da coluna `from_table` não puder ser derivado do nome `to_table`, você poderá usar a opção `:column`. Use a opção `:primary_key` se a chave primária referenciada não for `:id`.

Por exemplo, para adicionar uma chave estrangeira na `articles.reviewer` que referência `authors.email`:

```bash
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

Ao executar essa migração, o Rails criará uma chave estrangeira na coluna `reviewer` da tabela `articles` que referencia a coluna `email` na tabela `authors`. Isso ajudará a manter a integridade referencial entre as tabelas.

Por exemplo, se tivermos um artigo na tabela `articles` e quisermos definir quem é o revisor desse artigo, podemos inserir o `email` de um autor existente na tabela `authors` na coluna `reviewer` desse artigo. Essa referência garante que só podemos inserir emails que já existem na tabela `authors`, mantendo a integridade dos dados.

Várias outras opções, como `name`, `on_delete`, `if_not_exists`, `validate` e `deferrable` são suportadas por `add_foreign_key`.

Chaves estrangeiras também podem ser removidas usando `remove_foreign_key`.

```bash
# let Active Record figure out the column name
remove_foreign_key :accounts, :branches

# remove foreign key for a specific column
remove_foreign_key :accounts, column: :owner_id
```

Às vezes, o valor de uma única coluna não é suficiente para identificar exclusivamente cada linha de uma tabela, mas uma combinação de duas ou mais colunas identifica-a exclusivamente. Esse pode ser o caso ao usar um esquema de banco de dados legado sem uma única coluna `id` como chave primária ou ao alterar esquemas para fragmentação ou multitenancy.

Você pode criar uma tabela com uma chave primária composta passando a opção `:primary_key create_table` com um valor de array:

```ruby
class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products, primary_key: [:customer_id, :product_sku] do |t|
      t.integer :customer_id
      t.string :product_sku
      t.text :description
    end
  end
end
```

Se os auxiliares fornecidos pelo Active Record não forem suficientes, você pode usar o execute método para executar SQL arbitrário:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

O método `change` é a principal forma de escrever migrações. Funciona na maioria dos casos em que o Active Record sabe como reverter automaticamente as ações de uma migração. Abaixo estão algumas das ações que apoiam `change`:

- `add_check_constraint`: Adiciona uma restrição de verificação a uma coluna de uma tabela.
- `add_column`: Adiciona uma nova coluna a uma tabela existente.
- `add_foreign_key`: Adiciona uma chave estrangeira a uma tabela existente para estabelecer uma relação com outra tabela.
- `add_index`: Adiciona um índice a uma ou mais colunas de uma tabela para otimizar consultas.
- `add_reference`: Adiciona uma referência a outra tabela, geralmente criando uma coluna que referencia a chave primária de outra tabela.
- `add_timestamps`: Adiciona as colunas created_at e updated_at a uma tabela para acompanhar automaticamente quando os registros foram criados e atualizados.
- `change_column_comment`: Altera o comentário de uma coluna em uma tabela.
- `change_column_default`: Altera o valor padrão de uma coluna em uma tabela.
- `change_column_null`: Altera a opção NULL de uma coluna em uma tabela.
- `change_table_comment`: Altera o comentário de uma tabela.
- `create_join_table`: Cria uma tabela de junção para estabelecer uma relação muitos-para-muitos entre duas tabelas existentes.
- `create_tbale`: Cria uma nova tabela no banco de dados.
- `disable_extension`: Desabilita uma extensão do banco de dados.
- `drop_join_table`: Remove uma tabela de junção criada anteriormente.
- `drop_table`: Remove uma tabela existente do banco de dados.
- `enable_extension`: Habilita uma extensão do banco de dados.
- `remove_check_constraint`: Remove uma restrição de verificação de uma coluna.
- `remove_column`: Remove uma coluna de uma tabela existente.
- `remove_columns`: Remove uma ou mais colunas de uma tabela existente.
- `remove_foreign_key`: Remove uma chave estrangeira de uma tabela existente.
- `remove_index`: Remove um índice de uma ou mais colunas de uma tabela existente.
- `remove_reference`: Remove uma referência de outra tabela, geralmente removendo uma coluna que referencia a chave primária de outra tabela.
- `remove_timestamps`: Remove as colunas created_at e updated_at de uma tabela.
- `rename_column`: Renomeia uma coluna em uma tabela existente.
- `rename_index`: Renomeia um índice em uma tabela existente.
- `rename_table`: Renomeia uma tabela existente.

`change_table` também é reversível, desde que o bloco chame apenas operações reversíveis como as listadas acima.

Se precisar usar qualquer outro método, você deve usar `reversible` ou escrever os métodos `up`e `down` em vez de usar o método `change`.

Migrações complexas podem exigir um processamento que o Active Record não sabe como reverter. Você pode usar `reversible` para especificar o que fazer ao executar uma migração e o que mais fazer ao revertê-la. Por exemplo:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # create a distributors view
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end

    add_column :users, :address, :string
  end
end
```

. O método reversible permite definir operações que podem ser executadas tanto ao subir (up) quanto ao descer (down) a migração, tornando a migração reversível.

Aqui está uma explicação do que está acontecendo dentro da migração:

create_table :distributors do |t| ... end: Isso cria uma tabela chamada distributors com uma coluna zipcode.

reversible do |direction| ... end: Dentro do bloco reversible, estamos definindo duas ações: uma para quando a migração é aplicada (up) e outra para quando é revertida (down).

direction.up do ... end: Dentro desta seção, estamos criando uma view chamada distributors_view, que seleciona o id e o zipcode da tabela distributors.

direction.down do ... end: Dentro desta seção, estamos excluindo a view distributors_view.

add_column :users, :address, :string: Por fim, estamos adicionando uma coluna chamada address à tabela users.

O que torna esse código interessante é que a criação da view distributors_view é encapsulada dentro do método reversible, o que significa que o Rails pode desfazer a operação de criação da view automaticamente se a migração for revertida. Isso é possível porque o Rails sabe como reverter a operação executada dentro do bloco direction.up.

Assim, se essa migração for revertida, o Rails primeiro executará a operação dentro de direction.down, que remove a view distributors_view, e em seguida reverterá as operações fora do bloco reversible, como a exclusão da tabela distributors e a remoção da coluna address da tabela users. Isso garante que a migração seja totalmente reversível e não deixe o banco de dados em um estado inconsistente.


Você também pode usar o estilo antigo de migração usando métodos `up`e `down` em vez do  método `change`.

O método `up` deve descrever a transformação que você gostaria de fazer no seu esquema, e o método `down` da sua migração deve reverter as transformações feitas pelo método `up`. Em outras palavras, o esquema do banco de dados deve permanecer inalterado se você fizer um `up` seguido por um `down`.

Por exemplo, se você criar uma tabela no método `up`, deverá soltá-la no método `down`. É aconselhável realizar as transformações precisamente na ordem inversa em que foram feitas no método `up`. O exemplo na seção `reversible` é equivalente a:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.1]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # create a distributors view
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :address, :string
  end

  def down
    remove_column :users, :address

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

Às vezes, a sua migração fará algo que é simplesmente irreversível; por exemplo, pode destruir alguns dados.

Nesses casos, você pode subir um `ActiveRecord::IrreversibleMigration` no seu bloco `down`.

Se alguém tentar reverter sua migração, uma mensagem de erro será exibida informando que isso não pode ser feito.

Suponha que temos uma migração que adiciona uma coluna a uma tabela, mas essa alteração é irreversível, pois a remoção da coluna poderia causar a perda de dados importantes. Aqui está como você pode usar ActiveRecord::IrreversibleMigration para lidar com isso:

```ruby
class AddColumnIrreversibleMigration < ActiveRecord::Migration[7.1]
  def up
    add_column :users, :phone_number, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot reverse irreversible migration"
  end
end
```

No método up, estamos adicionando uma coluna chamada phone_number à tabela users.

No método down, estamos lançando uma exceção ActiveRecord::IrreversibleMigration. Isso indica que a migração não pode ser revertida de forma segura.

Se alguém tentar reverter essa migração, uma mensagem de erro será exibida, informando que isso não pode ser feito devido à natureza irreversível da migração.

Esta abordagem é útil quando você tem alterações em sua migração que não podem ser desfeitas de forma segura sem correr o risco de perder dados ou causar inconsistências no banco de dados. O uso de ActiveRecord::IrreversibleMigration ajuda a garantir que você seja avisado quando uma reversão não é possível.


Você pode usar a capacidade do Active Record para reverter migrações usando o método `revert`:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.1]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

`revert ExampleMigration`: Este comando irá reverter a migração ExampleMigration, ou seja, desfazer todas as alterações que foram feitas nessa migração. Se a migração ExampleMigration adicionou ou removeu alguma tabela, coluna, índice, etc., essas alterações serão desfeitas.

`create_table(:apples) do |t| ... end`: Após reverter a migração ExampleMigration, o código continua criando uma nova tabela chamada apples com uma coluna variety.

O método `revert` também aceita um bloco de instruções para reverter. Isto pode ser útil para reverter partes selecionadas de migrações anteriores.

Por exemplo, vamos imaginar que `ExampleMigration` está comprometido e mais tarde é decidido que uma visão de Distribuidores não é mais necessária.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    revert do
      # copy-pasted code from ExampleMigration
      reversible do |direction|
        direction.up do
          # create a distributors view
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
          SQL
        end
      end

      # The rest of the migration was ok
    end
  end
end
```

Essencialmente, este código está revertendo as alterações feitas dentro do bloco `revert`, que é uma cópia do código da `ExampleMigration`, enquanto aplica o resto da migração normalmente. Isso pode ser útil se você quiser reverter apenas uma parte específica de uma migração, enquanto mantém o resto dela intacto.

A mesma migração também poderia ter sido escrita sem usar, `revert` mas isso envolveria mais algumas etapas:

- Inverta a ordem de `create_table` e `reversible`.
- Substituir `create_table`com `drop_table`.
- Por fim, substitua `up` por `down` e vice-versa.
- Tudo isso é resolvido por `revert`.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.1]
  def change
    # Criação da view apenas se estiver subindo a migração
    reversible do |direction|
      direction.up do
        # create a distributors view
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
    end

    # Criação da tabela 'apples'
    create_table :apples do |t|
      t.string :variety
    end

    # Remoção da view apenas se estiver descendo a migração
    reversible do |direction|
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
        SQL
      end
    end
  end
end
```

