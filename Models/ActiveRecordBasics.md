# Active Record Basics


## O que é o Active Record:

Active Record é o M em MVC – o modelo – que é a camada do sistema responsável por representar os dados e a lógica do negócio. O Active Record facilita a criação e uso de objetos de negócios cujos dados requerem armazenamento persistente em um banco de dados. É uma implementação do padrão Active Record que por si só é uma descrição de um sistema de mapeamento relacional de objetos.

Então, o Active Record no Ruby on Rails é uma parte super importante do framework que ajuda a lidar com bancos de dados de uma maneira bem fácil e organizada.

Imagine que você está construindo um site para uma loja de videogames, e você precisa armazenar informações sobre os jogos que eles têm em estoque, como o título, o preço e a plataforma. Em vez de escrever código complicado para se conectar ao banco de dados e gerenciar essas informações, o Active Record faz todo esse trabalho pesado para você.

Com o Active Record, você pode criar uma classe para representar cada tipo de dado que você quer armazenar, como uma classe "Game" para representar os jogos. Essa classe Game herda de uma classe especial fornecida pelo Active Record que já sabe como lidar com o banco de dados.

Então, você pode simplesmente criar um objeto da classe Game para cada jogo, preencher as informações, como o título e o preço, e salvar no banco de dados com apenas algumas linhas de código. O Active Record cuida de traduzir esses objetos em registros no banco de dados e vice-versa, tornando todo o processo de trabalhar com dados muito mais simples e eficiente!

O ORM, ou Mapeamento Objeto-Relacional, é uma ideia muito legal no mundo da programação, especialmente quando estamos falando sobre Ruby on Rails. Vou tentar te explicar isso de uma forma bem simples.

Imagina que você tem um mundo real com dois tipos de coisas: objetos, como carros, casas e pessoas, e bancos de dados, onde você armazena informações sobre essas coisas, como o modelo do carro, a cor da casa ou o nome da pessoa.

Agora, às vezes, queremos que esses dois mundos - objetos e bancos de dados - conversem entre si, mas eles falam línguas diferentes. O ORM é como um tradutor que ajuda esses dois mundos a se entenderem.

No contexto do Ruby on Rails, o ORM mais usado é o Active Record, que é uma parte do Rails que faz essa tradução para nós. Ele mapeia, ou seja, relaciona, nossos objetos Ruby (como classes e instâncias dessas classes) com tabelas em um banco de dados relacional.

Então, em vez de lidar diretamente com consultas SQL (a linguagem dos bancos de dados), podemos trabalhar com nossos objetos Ruby como se estivéssemos lidando diretamente com os dados no banco de dados, o que é muito mais fácil e intuitivo para nós, desenvolvedores!

Resumindo, o ORM, como o Active Record no Ruby on Rails, nos ajuda a trabalhar com bancos de dados de uma forma mais fácil, usando nossos objetos Ruby, e fazendo toda a tradução de dados entre esses dois mundos para nós. É como ter um assistente que fala tanto "objeto" quanto "bancos de dados" e nos ajuda a nos comunicar entre eles. Legal, né?

![Definição Active Record](/imagens/definicao_active_record.JPG)

## Convenção de Nomenclaturas:

Por padrão, o Active Record utiliza algumas convenções de nomenclatura para descobrir como o mapeamento entre modelos e tabelas de banco de dados deve ser criado. Rails pluralizará seus nomes de classe para encontrar a respectiva tabela de banco de dados. Então, para uma class 'Book', você deve ter uma tabela de banco de dados chamada 'books'.

- Classe Modelo - Singular com a primeira letra de cada palavra em maiúscula (por exemplo, BookClub).
- Tabela de banco de dados - Plural com sublinhados separando palavras (por exemplo, book_clubs).

| Modelo/Classe |	Tabela/Esquema |
| :---: | :---:|
|Article	| articles |
|LineItem |	line_items |
|Deer	| deers |
|Mouse |	mice |
|Person |	people |

O Active Record usa convenções de nomenclatura para as colunas nas tabelas do banco de dados, dependendo da finalidade dessas colunas.

- Chaves estrangeiras - Esses campos devem ser nomeados seguindo o padrão singularized_table_name_id(por exemplo, item_id, order_id). Estes são os campos que o Active Record irá procurar quando você criar associações entre seus modelos.
- Chaves primárias - Por padrão, o Active Record usará uma coluna inteira nomeada 'id' como chave primária da tabela ( bigint para PostgreSQL e MySQL, integer para SQLite). Ao usar Active Record Migrations para criar suas tabelas, esta coluna será criada automaticamente.

Existem também alguns nomes de colunas opcionais que adicionarão recursos adicionais às instâncias do Active Record:

- created_at- É definido automaticamente para a data e hora atuais quando o registro é criado pela primeira vez.
- updated_at- É definido automaticamente para a data e hora atuais sempre que o registro é criado ou atualizado.

- lock_version: Este é usado para implementar o conceito de "bloqueio otimista" em um modelo. Imagine que você tem um registro no banco de dados que está sendo editado por dois usuários ao mesmo tempo. O lock_version é uma maneira de evitar que uma pessoa sobrescreva as alterações feitas pela outra. O Rails automaticamente gerencia isso para você. Aqui está um exemplo de como você poderia usar o lock_version em um modelo:

```ruby
class Product < ApplicationRecord
  # Assume que a tabela products possui uma coluna chamada lock_version
end

# Suponha que você tenha um produto específico com id = 1
product = Product.find(1)

# Agora, você e outra pessoa estão editando este produto ao mesmo tempo

# Vamos dizer que você atualizou o nome do produto
product.update(name: "Novo Nome do Produto")

# A outra pessoa também tentou atualizar o produto ao mesmo tempo
# Mas, como o lock_version mudou depois que você carregou o produto, isso falhará com uma exceção
product_another_person = Product.find(1)
product_another_person.update(name: "Outro Nome do Produto")
# Isso levantaria uma exceção devido à diferença de lock_version
```

- type: Essa coluna é usada quando você está usando herança de tabela única (STI - Single Table Inheritance). Com o STI, várias classes de modelo compartilham uma tabela de banco de dados, e a coluna type é usada para determinar de que tipo é cada registro. Aqui está um exemplo básico:

```ruby
class Animal < ApplicationRecord
  # Assume que a tabela animals possui uma coluna chamada type
end

class Dog < Animal
end

class Cat < Animal
end

# Ao salvar um objeto Dog no banco de dados:
dog = Dog.create(name: "Rex")
# Rails irá automaticamente definir o valor da coluna `type` como "Dog"
```

- (association_name)_type: Esta coluna é usada para associações polimórficas. Uma associação polimórfica é uma associação em que o modelo pode pertencer a mais de um tipo de modelo. Por exemplo, se você tiver um modelo de Comment que pode ser associado a vários outros modelos, como Post e Image, você pode usar uma associação polimórfica. Aqui está um exemplo básico:

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Image < ApplicationRecord
  has_many :comments, as: :commentable
end

# Para usar isso, você precisa adicionar uma coluna `commentable_type` à sua tabela de comentários.
# Isso será automaticamente gerenciado pelo Rails.
```

- (table_name)_count: Esta é uma coluna usada para armazenar em cache o número de objetos associados. É útil para otimização de desempenho, especialmente em situações em que você precisa frequentemente contar o número de objetos associados. Aqui está um exemplo básico:

```ruby
class Article < ApplicationRecord
  has_many :comments
end

# Suponha que você tenha uma coluna comments_count na tabela articles.
# Rails automaticamente atualizará esta coluna sempre que você adicionar ou remover um comentário associado a um artigo.
```

## Criando Modelos

Ao gerar uma aplicação, uma classe abstrata ApplicationRecordserá criada em app/models/application_record.rb. Esta é a classe base para todos os modelos em um aplicativo e é o que transforma uma classe Ruby regular em um modelo Active Record.

Para criar modelos Active Record, crie uma subclasse da ApplicationRecordclasse e pronto:

```ruby
class Product < ApplicationRecord
end
```

Isto criará um modelo 'Product', mapeado para uma tabela 'products' no banco de dados. Ao fazer isso, você também poderá mapear as colunas de cada linha dessa tabela com os atributos das instâncias do seu modelo. Suponha que a tabela 'products' foi criada usando uma instrução SQL (ou uma de suas extensões) como:

```sql
CREATE TABLE products (
  id int(11) NOT NULL auto_increment,
  name varchar(255),
  PRIMARY KEY  (id)
);
```

O esquema acima declara uma tabela com duas colunas: 'id' e 'name'. Cada linha desta tabela representa um determinado produto com estes dois parâmetros. Assim, você seria capaz de escrever código como o seguinte:

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

## Substituindo as Convenções de Nomenclatura

E se você precisar seguir uma convenção de nomenclatura diferente ou usar seu aplicativo Rails com um banco de dados legado? Não tem problema, você pode substituir facilmente as convenções padrão.

Como 'ApplicationRecord' herda de 'ActiveRecord::Base', os modelos do seu aplicativo terão vários métodos úteis disponíveis. Por exemplo, você pode usar o método 'ActiveRecord::Base.table_name=' para personalizar o nome da tabela que deve ser usada:

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

Se fizer isso, você terá que definir manualmente o nome da classe que hospeda os fixtures ( my_products.yml) usando o método 'set_fixture_class' em sua definição de teste:

```ruby
# test/models/product_test.rb
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  # ...
end
```
Também é possível substituir a coluna que deve ser usada como chave primária da tabela usando o método 'ActiveRecord::Base.primary_key=':

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

![Aviso Sobre Mudanças de Nomenclaturas](/imagens/aviso_mudanca_nomenclaturas.JPG)


## CRUD: leitura e gravação de dados

CRUD é um acrônimo para os quatro verbos que usamos para operar com dados: C reate, R ead, Update e D elete. O Active Record cria automaticamente métodos para permitir que um aplicativo leia e manipule dados armazenados em suas tabelas.

### Criar (Criate)

Os objetos Active Record podem ser criados a partir de um hash, um bloco ou ter seus atributos definidos manualmente após a criação. O método 'new' retornará um novo objeto enquanto 'create' retornará o objeto e o salvará no banco de dados.

Por exemplo, dado um modelo 'User' com atributos de 'name' e 'occupation', a chamada 'create' do método criará e salvará um novo registro no banco de dados:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```

Usando o método 'new', um objeto pode ser instanciado sem ser salvo:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

### Ler (Read)

Active Record fornece uma API rica para acessar dados em um banco de dados. Abaixo estão alguns exemplos de diferentes métodos de acesso a dados fornecidos pelo Active Record.

```ruby
# return a collection with all users
users = User.all
```

```ruby
# return the first user
user = User.first
```

```ruby
# return the first user named David
david = User.find_by(name: 'David')
```

```ruby
# find all users named David who are Code Artists and sort by created_at in reverse chronological order
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

### Atualizações (Update)

Depois que um objeto Active Record for recuperado, seus atributos podem ser modificados e salvos no banco de dados.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

Um atalho para isso é usar nomes de atributos de mapeamento hash para o valor desejado, assim:

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

Isto é mais útil ao atualizar vários atributos de uma só vez.

Se quiser atualizar vários registros em massa sem retornos de chamada ou validações , você pode atualizar o banco de dados diretamente usando update_all:

```ruby
User.update_all max_login_attempts: 3, must_change_password: true
```

### Excluir (Delete)

Da mesma forma, uma vez recuperado, um objeto Active Record pode ser destruído, o que o remove do banco de dados.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

Se desejar excluir vários registros em massa, você pode usar o método destroy_by ou :destroy_all

```ruby
# find and delete all users named David
User.destroy_by(name: 'David')

# delete all users
User.destroy_all
```

## Validações

O Active Record permite validar o estado de um modelo antes que ele seja gravado no banco de dados. Existem vários métodos que você pode usar para verificar seus modelos e validar se um valor de atributo não está vazio, se é único e ainda não está no banco de dados, segue um formato específico e muito mais.

Métodos como 'save' 'create' 'update' validam um modelo antes de persisti lo no banco de dados. Quando um modelo é inválido, esses métodos retornam 'false' e nenhuma operação de banco de dados é executada. Todos esses métodos têm uma 'bang' contraparte (ou seja, 'save!', 'create!' e 'update!'), que são mais rigorosos, pois geram uma execução ActiveRecord::RecordInvalid quando a validação falha. Um exemplo rápido para ilustrar:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end
```

```ruby
irb> user = User.new
itb> user.save
=> flase
irb> user.save!
=> ActiveRecord::RecordInvalid: Validation failed: Name can´t be blank
```

## Retornos de chamada (Callbacks)

Os retornos de chamada do Active Record permitem anexar código a determinados eventos no ciclo de vida de seus modelos. Isso permite adicionar comportamento aos seus modelos executando código de forma transparente quando esses eventos ocorrem, como quando você cria um novo registro, atualiza-o, destrói-o e assim por diante.

```ruby
class User < ApplicationRecord
  after_create :log_new_user

  private
    def log_new_user
      puts "A new user was registered"
    end
end
```
```ruby
irb> @user = User.create
=> A new user was registered
```

## Migrações (Migrations)

Rails fornece uma maneira conveniente de gerenciar alterações em um esquema de banco de dados por meio de migrações. As migrações são escritas em uma linguagem específica do domínio e armazenadas em arquivos que são executados em qualquer banco de dados compatível com o Active Record.

Aqui está uma migração que cria uma nova tabela chamada 'publications':

```ruby
class CreatePublications < ActiveRecord::Migration[7.1]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

Observe que o código acima é independente de banco de dados: ele será executado em 'MySQL', 'PostgreSQL', 'SQLite' e outros.

Rails rastreia quais migrações foram confirmadas no banco de dados e as armazena em uma tabela vizinha no mesmo banco de dados chamada 'schema_migrations'.

Para executar a migração e criar a tabela, você executaria `rails db:migrate`, e para revertê-la e excluir a tabela, `rails db:rollback`.

## Associações (Associations)

As associações do `Active Record` permitem definir relacionamentos entre modelos. As associações podem ser usadas para descrever relacionamentos `um-para-um`, `um-para-muitos` e `muitos-para-muitos`. Por exemplo, um relacionamento como “ O autor tem muitos livros” pode ser definido da seguinte forma:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

