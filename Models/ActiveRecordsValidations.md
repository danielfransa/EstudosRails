# Active Record Validations

## Validations Overview

Aqui está um exemplo de validação muito simples:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```bash
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Como você pode ver, nossa validação nos permite saber que nossa validação `Person` não é válida sem um atributo `name`. O segundo `Person` não será persistido no banco de dados.

Antes de entrarmos em mais detalhes, vamos falar sobre como as validações se enquadram no panorama geral do seu aplicativo.

###  Por que usar validações?

As validações são usadas para garantir que apenas dados válidos sejam salvos em seu banco de dados. Por exemplo, pode ser importante para seu aplicativo garantir que cada usuário forneça um endereço de e-mail e um endereço para correspondência válidos. As validações em nível de modelo são a melhor maneira de garantir que apenas dados válidos sejam salvos em seu banco de dados. Eles são independentes de banco de dados, não podem ser ignorados pelos usuários finais e são fáceis de testar e manter. Rails fornece ajudantes integrados para necessidades comuns e também permite que você crie seus próprios métodos de validação.

Existem várias outras maneiras de validar dados antes de salvá-los em seu banco de dados, incluindo restrições nativas de banco de dados, validações no lado do cliente e validações no nível do controlador. Aqui está um resumo dos prós e contras:

- As restrições do banco de dados e/ou procedimentos armazenados tornam os mecanismos de validação dependentes do banco de dados e podem dificultar os testes e a manutenção. Entretanto, se seu banco de dados for usado por outros aplicativos, pode ser uma boa ideia usar algumas restrições no nível do banco de dados. Além disso, as validações em nível de banco de dados podem lidar com segurança com algumas coisas (como exclusividade em tabelas muito utilizadas) que podem ser difíceis de implementar de outra forma.
- As validações do lado do cliente podem ser úteis, mas geralmente não são confiáveis ​​se usadas sozinhas. Se forem implementados usando JavaScript, poderão ser ignorados se o JavaScript estiver desativado no navegador do usuário. No entanto, se combinada com outras técnicas, a validação do lado do cliente pode ser uma maneira conveniente de fornecer feedback imediato aos usuários à medida que utilizam seu site.
- As validações no nível do controlador podem ser tentadoras de usar, mas muitas vezes se tornam complicadas e difíceis de testar e manter. Sempre que possível, é uma boa ideia manter seus controladores simples, pois isso fará com que seja um prazer trabalhar com seu aplicativo no longo prazo.

Escolha-os em determinados casos específicos. A opinião da equipe Rails é que as validações em nível de modelo são as mais apropriadas na maioria das circunstâncias.


### Quando acontece a validação?

Existem dois tipos de objetos Active Record: aqueles que correspondem a uma linha dentro do seu banco de dados e aqueles que não correspondem. Quando você cria um novo objeto, por exemplo, usando o método `new`, esse objeto ainda não pertence ao banco de dados. Depois de chamar `save` esse objeto, ele será salvo na tabela de banco de dados apropriada. Active Record usa o método `new_record?` de instância para determinar se um objeto já está no banco de dados ou não. Considere a seguinte classe Active Record:

```ruby
class Person < ApplicationRecord
end
```

Podemos ver como funciona observando alguns resultados `bin/rails console`:

```bash
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

Criar e salvar um novo registro enviará uma operação `INSERT` SQL ao banco de dados. A atualização de um registro existente enviará uma operação `UPDATE` SQL. As validações normalmente são executadas antes que esses comandos sejam enviados ao banco de dados. Se alguma validação falhar, o objeto será marcado como inválido e o Active Record não executará a operação `INSERT` ou `UPDATE`. Isso evita armazenar um objeto inválido no banco de dados. Você pode optar por executar validações específicas quando um objeto é criado, salvo ou atualizado.

![Aviso sobre validação](/imagens/acitive_record_validations1.JPG)

Os métodos a seguir acionam validações e salvarão o objeto no banco de dados somente se o objeto for válido:

`create`
`create!`
`save`
`save!`
`update`
`update!`

As versões bang (por exemplo `save!`, ) geram uma exceção se o registro for inválido. As versões não-bang não: `save` e `update` tem um retorno `false` e `create` retornam o objeto.


### Ignorando Validações

Os métodos a seguir ignoram as validações e salvarão o objeto no banco de dados, independentemente de sua validade. Eles devem ser usados ​​com cautela.

- `decrement!`
- `decrement_counter`
- `increment!`
- `increment_counter`
- `insert`
- `insert!`
- `insert_all`
- `insert_all!`
- `toggle!`
- `touch`
- `touch_all`
- `update_all`
- `update_attribute`
- `update_column`
- `update_columns`
- `update_counters`
- `upsert`
- `upsert_all`

Observe que `save` também tem a capacidade de pular validações se for passado validate: `false` como argumento. Esta técnica deve ser usada com cautela.
- `save(validate: false)`

### valid? e invalid?


Antes de salvar um objeto Active Record, Rails executa suas validações. Se essas validações produzirem algum erro, o Rails não salva o objeto.

Você também pode executar essas validações por conta própria. valid?aciona suas validações e retorna verdadeiro se nenhum erro for encontrado no objeto e falso caso contrário. Como você viu acima:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```bash
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Após o Active Record realizar as validações, quaisquer falhas podem ser acessadas através do método `errors` de instância, que retorna uma coleção de erros. Por definição, um objeto é válido se esta coleção estiver vazia após a execução das validações.

Observe que um objeto instanciado com `new` não reportará erros mesmo que seja tecnicamente inválido, porque as validações são executadas automaticamente somente quando o objeto é salvo, como com os métodos `create` ou `.save`

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```bash
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can't be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can't be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

`invalid?` é o inverso de `valid?`. Ele aciona suas validações, retornando verdadeiro se algum erro for encontrado no objeto e falso caso contrário.

### errors[]

Para verificar se um determinado atributo de um objeto é válido ou não, você pode usar `errors[:attribute]`. Ele retorna uma matriz de todas as mensagens de erro do `:attribute`. Se não houver erros no atributo especificado, um array vazio será retornado.

Este método só é útil após a execução das validações, pois apenas inspeciona a coleta de erros e não aciona as validações em si. É diferente do método `ActiveRecord::Base#invalid?` explicado acima porque não verifica a validade do objeto como um todo. Ele apenas verifica se há erros encontrados em um atributo individual do objeto.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```bash
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

## Ajudantes de validação

O Active Record oferece muitos auxiliares de validação predefinidos que você pode usar diretamente nas definições de sua classe. Esses auxiliares fornecem regras de validação comuns. Cada vez que uma validação falha, um erro é adicionado à errors coleção do objeto, e isso está associado ao atributo que está sendo validado.

Cada auxiliar aceita um número arbitrário de nomes de atributos, portanto, com uma única linha de código você pode adicionar o mesmo tipo de validação a vários atributos.

Todos aceitam as opções `:on` e `:message`, que definem quando a validação deve ser executada e qual mensagem deve ser adicionada à errors coleção caso ela falhe, respectivamente. A opção `:on` assume um dos valores `:create` ou `:update`. Há uma mensagem de erro padrão para cada um dos auxiliares de validação. Essas mensagens são usadas quando a opção `:message` não é especificada. Vamos dar uma olhada em cada um dos ajudantes disponíveis.

![Aviso validations Helpers](/imagens/acitive_record_validations2.JPG)

### acceptance

Este método valida se uma caixa de seleção na interface do usuário foi marcada quando um formulário foi enviado. Normalmente, isso é usado quando o usuário precisa concordar com os termos de serviço do seu aplicativo, confirmar se algum texto foi lido ou qualquer conceito semelhante.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

Esta verificação é realizada somente se `terms_of_service` não for `nil`. A mensagem de erro padrão para este auxiliar é "deve ser aceita" . Você também pode passar uma mensagem personalizada por meio da opção `message`.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'must be abided' }
end
```

Também pode receber uma opção `:accept`, que determina os valores permitidos que serão considerados aceitáveis. O padrão é `['1', true]` e pode ser facilmente alterado.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

Esta validação é muito específica para aplicações web e esta 'aceitação' não precisa ser registrada em nenhum lugar do seu banco de dados. Se você não tiver um campo para isso, o auxiliar criará um atributo virtual. Se o campo existir em seu banco de dados, a opção `accept` deverá ser definida como ou include `true`, caso contrário a validação não será executada.


### confirmation

Você deve usar este auxiliar quando tiver dois campos de texto que devem receber exatamente o mesmo conteúdo. Por exemplo, você pode querer confirmar um endereço de e-mail ou uma senha. Esta validação cria um atributo virtual cujo nome é o nome do campo que deve ser confirmado com "_confirmation" anexado.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

No seu modelo de visualização você poderia usar algo como

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

![Aviso sobre a validação confirmation](/imagens/acitive_record_validations3.JPG)

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

Há também uma opção `:case_sensitive` que você pode usar para definir se a restrição de confirmação fará distinção entre maiúsculas e minúsculas ou não. Esta opção é padronizada como verdadeira.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

A mensagem de erro padrão para este auxiliar é "não corresponde à confirmação" . Você também pode passar uma mensagem personalizada por meio da opção `message`.

Geralmente ao utilizar este validador, você desejará combiná-lo com a opção `:if` de validar o campo `"_confirmation"` apenas quando o campo inicial for alterado e não sempre que você salvar o registro. Mais sobre validações condicionais posteriormente.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### comparison

Esta verificação validará uma comparação entre quaisquer dois valores comparáveis.

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

A mensagem de erro padrão para este auxiliar é "comparação falhada" . Você também pode passar uma mensagem personalizada por meio da messageopção.

Todas estas opções são suportadas:

- `:greater_than` - Especifica que o valor deve ser maior que o valor fornecido. A mensagem de erro padrão para esta opção é "deve ser maior que %{count}" .

```ruby
class Product < ApplicationRecord
  validates :price, numericality: { greater_than: 0 }
end
```
```ruby
class Product < ApplicationRecord
  validates :price, numericality: { greater_than: 0, message: "must be greater than zero" }
end
```
- `:greater_than_or_equal_to`- Especifica que o valor deve ser maior ou igual ao valor fornecido. A mensagem de erro padrão para esta opção é "deve ser maior ou igual a %{count}" .

```ruby
class Flight < ApplicationRecord
  validates :seats_reserved, numericality: { greater_than_or_equal_to: 1 }
end
```
```ruby
class Flight < ApplicationRecord
  validates :seats_reserved, numericality: { greater_than_or_equal_to: 1, message: "must be at least 1" }
end
```

- `:equal_to`- Especifica que o valor deve ser igual ao valor fornecido. A mensagem de erro padrão para esta opção é "must be equal to %{count}" .
```ruby
class Vote < ApplicationRecord
  validates :choice, inclusion: { in: %w(Sim Não Abstenção), message: "%{value} não é uma opção válida" }
end
```
```ruby
class Vote < ApplicationRecord
  validates :choice, inclusion: { in: %w(Sim Não Abstenção), message: "Escolha inválida. Por favor, escolha entre 'Sim', 'Não' ou 'Abstenção'." }
end
```

- `:less_than` - Especifica que o valor deve ser menor que o valor fornecido. A mensagem de erro padrão para esta opção é "must be less than %{count}" .
```ruby
class Product < ApplicationRecord
  validates :stock_quantity, numericality: { less_than: 100 }
end
```
```ruby
class Product < ApplicationRecord
  validates :stock_quantity, numericality: { less_than: 100, message: "deve ser menor do que 100" }
end
```

- `:less_than_or_equal_to` - Especifica que o valor deve ser menor ou igual ao valor fornecido. A mensagem de erro padrão para esta opção é "must be less than or equal to %{count}" .
:other_than- Especifica que o valor deve ser diferente do valor fornecido. A mensagem de erro padrão para esta opção é "must be other than %{count}" .
```ruby
class Booking < ApplicationRecord
  validates :ticket_quantity, numericality: { less_than_or_equal_to: 10 }
end
```
```ruby
class Booking < ApplicationRecord
  validates :ticket_quantity, numericality: { less_than_or_equal_to: 10, message: "não pode reservar mais do que 10 ingressos de uma vez" }
end
```

![Aviso sobre validate comparison](/imagens/acitive_record_validations4.JPG)


### format

Este auxiliar valida os valores dos atributos testando se eles correspondem a uma determinada expressão regular, que é especificada usando a opção `:with`.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

Inversamente, ao usar a opção `:without`, você pode exigir que o atributo especificado não corresponda à expressão regular.

Em ambos os casos, a opção  fornecida `:with` ou `:without` deve ser uma expressão regular ou um proc ou lambda que retorne uma.

A mensagem de erro padrão é "é inválido" .

Vamos supor que estamos construindo um sistema de cadastro de usuários e queremos garantir que o campo de e-mail contenha um formato válido de e-mail. Aqui está como poderíamos fazer isso:

```ruby
class User < ApplicationRecord
  validates :email, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/,
    message: "formato de e-mail inválido" }
end
```

Suponha que em nosso sistema de cadastro de usuários, queremos garantir que o campo de username não contenha caracteres especiais. Podemos fazer isso usando a opção `:without`:

```ruby
class User < ApplicationRecord
  validates :username, format: { without: /[^a-zA-Z0-9]/,
    message: "o username não pode conter caracteres especiais" }
end
```

![Aviso sobre Format](/imagens/acitive_record_validations5.JPG)


### inclusion

Este auxiliar valida se os valores dos atributos estão incluídos em um determinado conjunto. Na verdade, este conjunto pode ser qualquer objeto enumerável.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

O helper `inclusion` possui uma opção `:in` que recebe o conjunto de valores que serão aceitos. A opção `:in` possui um alias chamado `:within` que você pode usar para a mesma finalidade, se desejar. O exemplo anterior usa a opção `:message` para mostrar como você pode incluir o valor do atributo. Para opções completas, consulte a documentação da mensagem .

A mensagem de erro padrão para este auxiliar é "não está incluído na lista".


### exclusion

O oposto de `inclusion` é... `exclusion`!

Este auxiliar valida que os valores dos atributos não estão incluídos em um determinado conjunto. Na verdade, este conjunto pode ser qualquer objeto enumerável.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

O helper `exclusion` possui uma opção `:in` que recebe o conjunto de valores que não serão aceitos para os atributos validados. A opção `:in` possui um alias chamado `:within` que você pode usar para a mesma finalidade, se desejar. Este exemplo usa a opção `:message` para mostrar como você pode incluir o valor do atributo. Para opções completas para o argumento da mensagem, consulte a documentação da mensagem .

A mensagem de erro padrão é "está reservado" .

Alternativamente a um enumerável tradicional (como um Array), você pode fornecer um proc, lambda ou símbolo que retorne um enumerável. Se o enumerável for um intervalo numérico, de hora ou de data e hora, o teste será realizado com `Range#cover?`, caso contrário, com `include?`. Ao usar um proc ou lambda, a instância em validação é passada como argumento.

### length

Este auxiliar valida o comprimento dos valores dos atributos. Ele fornece uma variedade de opções, para que você possa especificar restrições de comprimento de diferentes maneiras:

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

As possíveis opções de restrição de comprimento são:

- `:minimum` - O atributo não pode ter comprimento inferior ao especificado.
- `:maximum` - O atributo não pode ter mais que o comprimento especificado.
- `:in` (ou `:within`) - O comprimento do atributo deve ser incluído em um determinado intervalo. O valor para esta opção deve ser um intervalo.
- `:is`- O comprimento do atributo deve ser igual ao valor fornecido.

As mensagens de erro padrão dependem do tipo de validação de comprimento que está sendo executada. Você pode personalizar essas mensagens usando as opções `:wrong_length`, `:too_long`, `:too_short` e a opção `%{count}` é como um espaço reservado para o número correspondente à restrição de comprimento que está sendo usada. Você ainda pode usar a opção `:message` para especificar uma mensagem de erro.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

Observe que as mensagens de erro padrão são plurais (por exemplo, "é muito curto (o mínimo é `%{count}` caracteres)"). Por esse motivo, quando `:minimum` for 1 você deve fornecer uma mensagem personalizada ou usar `presence: true`. Quando `:in` ou `:within` tiver um limite inferior de 1, você deverá fornecer uma mensagem personalizada ou usar presence antes de length.

![Aviso validation length](/imagens/acitive_record_validations6.JPG)


### numericality

Este auxiliar valida que seus atributos possuem apenas valores numéricos. Por padrão, ele corresponderá a um sinal opcional seguido por um número inteiro ou de ponto flutuante.

Para especificar que apenas números inteiros são permitidos, defina `:only_integer` como verdadeiro. Em seguida, usará a seguinte expressão regular para validar o valor do atributo.

```bash
/\A[+-]?\d+\z/
```

Caso contrário, tentará converter o valor em um número usando `Float`. `Floats` são convertidos usando `BigDecimal` o valor de precisão da coluna ou um máximo de 15 dígitos.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

A mensagem de erro padrão `:only_integer` é: "deve ser um número inteiro" .

Além disso `:only_integer`, este auxiliar também aceita a opção `:only_numeric` que especifica que o valor deve ser uma instância de `Numeric` e tenta analisar o valor se for um String.

![Aviso validate mumericality](/imagens/acitive_record_validations7.JPG)

A mensagem de erro padrão quando nenhuma opção é especificada é: "is not a number" .

Existem também muitas opções que podem ser usadas para adicionar restrições a valores aceitáveis:

- `:greater_than`- Especifica que o valor deve ser maior que o valor fornecido. A mensagem de erro padrão para esta opção é: "deve ser maior que %{count}" .
- `:greater_than_or_equal_to` - Especifica que o valor deve ser maior ou igual ao valor fornecido. A mensagem de erro padrão para esta opção é: "deve ser maior ou igual a %{count}" .
- `:equal_to` - Especifica que o valor deve ser igual ao valor fornecido. A mensagem de erro padrão para esta opção é: "must be equal to %{count}" .
- `:less_than` - Especifica que o valor deve ser menor que o valor fornecido. A mensagem de erro padrão para esta opção é: "must be less than %{count}" .
- `:less_than_or_equal_to` - Especifica que o valor deve ser menor ou igual ao valor fornecido. A mensagem de erro padrão para esta opção é: "must be less than or equal to %{count}".
- `:other_than` - Especifica que o valor deve ser diferente do valor fornecido. A mensagem de erro padrão para esta opção é: "must be other than %{count}" .
- `:in` - Especifica que o valor deve estar no intervalo fornecido. A mensagem de erro padrão para esta opção é: "must be in %{count}" .
- `:odd` - Especifica que o valor deve ser um número ímpar. A mensagem de erro padrão para esta opção é: "must be odd" .
- `:even` - Especifica que o valor deve ser um número par. A mensagem de erro padrão para esta opção é: "must be even" .


### presence

Este auxiliar valida que os atributos especificados não estão vazios. Ele usa o método `Object#blank?` para verificar se o valor é `nil` uma string em branco, ou seja, uma string vazia ou composta por espaços em branco.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

Se quiser ter certeza de que uma associação está presente, você precisará testar se o próprio objeto associado está presente, e não a chave estrangeira usada para mapear a associação. Desta forma, não só é verificado se a chave estrangeira não está vazia, mas também se o objeto referenciado existe.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end 
```

Para validar registros associados cuja presença é obrigatória, deve-se especificar a opção `:inverse_of` de associação:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```
![aviso sobre validate associação](/imagens/acitive_record_validations8.JPG)

Se você validar a presença de um objeto associado por meio de um relacionamento `has_one` ou `has_many`, ele verificará se o objeto não é `blank?` nem `marked_for_destruction?`.

Como `false.blank?` é verdade, se você deseja validar a presença de um campo booleano você deve usar uma das seguintes validações:

```ruby
# Value _must_ be true or false
validates :boolean_field_name, inclusion: [true, false]
# Value _must not_ be nil, aka true or false
validates :boolean_field_name, exclusion: [nil]
```

Ao usar uma dessas validações, você garantirá que o valor NÃO será `nil` o que resultaria em um valor `NULL` na maioria dos casos.

A mensagem de erro padrão é: "não pode ficar em branco".


### absence

Este auxiliar valida que os atributos especificados estão ausentes. Ele usa o método `Object#present?` para verificar se o valor não é nulo ou uma string em branco, ou seja, uma string vazia ou composta por espaços em branco.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

Se quiser ter certeza de que uma associação está ausente, você precisará testar se o próprio objeto associado está ausente e não a chave estrangeira usada para mapear a associação.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

Para validar registros associados cuja ausência é obrigatória, deve-se especificar a opção `:inverse_of` de associação:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

![aviso sobre validate associação](/imagens/acitive_record_validations8.JPG)

Se você validar a ausência de um objeto associado por meio de um relacionamento `has_one` ou `has_many`, ele verificará se o objeto não é `present?` nem `marked_for_destruction?`.

Como `false.present?` é falso, se você quiser validar a ausência de um campo booleano você deve usar `validates :field_name, exclusion: { in: [true, false] }`.

A mensagem de erro padrão é: "deve estar em branco".


### uniqueness

Este auxiliar valida que o valor do atributo é único antes de o objeto ser salvo.


```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

A validação acontece através da realização de uma consulta SQL na tabela do modelo, buscando um registro existente com o mesmo valor naquele atributo.

Existe uma opção `:scope` que você pode usar para especificar um ou mais atributos que são usados ​​para limitar a verificação de exclusividade:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```

![Aviso validate uniqueness](/imagens/acitive_record_validations9.JPG)

Para adicionar uma restrição de exclusividade ao seu banco de dados, use a instrução `add_index` em uma migração e inclua a opção `unique: true`.

Caso deseje criar uma restrição de banco de dados para evitar possíveis violações de uma validação de exclusividade usando a opção `:scope`, você deve criar um índice exclusivo em ambas as colunas do seu banco de dados. Consulte o manual do MySQL para obter mais detalhes sobre índices de múltiplas colunas ou o manual do PostgreSQL para exemplos de restrições exclusivas que se referem a um grupo de colunas.

Há também uma opção `:case_sensitive` que você pode usar para definir se a restrição de exclusividade fará distinção entre maiúsculas e minúsculas ou se deverá respeitar o agrupamento padrão do banco de dados. Esta opção tem como padrão respeitar o agrupamento padrão do banco de dados.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

![Aviso validate uniqueness banco de dados](/imagens/acitive_record_validations10.JPG)

Existe uma opção `:conditions` que permite especificar condições adicionais como um fragmento `WHERE SQL` para limitar a pesquisa de restrição de exclusividade (por exemplo `conditions: -> { where(status: 'active') }`, ).

A mensagem de erro padrão é: "já foi tomada" .

Consulte `validates_uniqueness_of` para obter mais informações.


### validates_associated

Você deve usar este auxiliar quando seu modelo tiver associações que sempre precisam ser validadas. Cada vez que você tentar salvar seu objeto, `valid?` será chamado para cada um dos objetos associados.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

Esta validação funcionará com todos os tipos de associação.

![Aviso validate validates_associated](/imagens/acitive_record_validations11.JPG)

A mensagem de erro padrão `validates_associated` é: "is invalid". Observe que cada objeto associado conterá sua própria coleção `errors`; os erros não chegam ao modelo de chamada.

![Aviso validate validates_associated2](/imagens/acitive_record_validations12.JPG)


### validates_each

Este auxiliar valida atributos em um bloco. Não possui uma função de validação predefinida. Você deve criar um usando um bloco, e cada atributo passado `validates_each` será testado em relação a ele.

No exemplo a seguir, rejeitaremos nomes e sobrenomes que comecem com letras minúsculas.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if /\A[[:lower:]]/.match?(value)
  end
end
```

O bloco recebe o registro, o nome do atributo e o valor do atributo.

Você pode fazer o que quiser para verificar dados válidos dentro do bloco. Se sua validação falhar, você deverá adicionar um erro ao modelo, tornando-o inválido.


### validates_with

Este auxiliar passa o registro para uma classe separada para validação.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

Não há mensagem de erro padrão para validates_with. Você deve adicionar erros manualmente à coleção de erros do registro na classe do validador.

![aviso validate validates_with](/imagens/acitive_record_validations13.JPG)

Para implementar o método de validação, você deve aceitar um parâmetro `record` na definição do método, que é o registro a ser validado.

Se você quiser adicionar um erro em um atributo específico, passe-o como primeiro argumento, como `record.errors.add(:first_name, "please choose another
name")`. Abordaremos os erros de validação com mais detalhes posteriormente.

```ruby
def validate(record)
  if record.some_field != "acceptable"
    record.errors.add :some_field, "this field is unacceptable"
  end
end
```

O auxiliar `validates_with` pega uma classe ou uma lista de classes para usar na validação.

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

Como todas as outras validações, `validates_with` usa as opções `:if`, `:unless` e `:on`. Se você passar qualquer outra opção, essas opções serão enviadas para a classe validadora como `:options`

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Observe que o validador será inicializado apenas uma vez durante todo o ciclo de vida da aplicação, e não em cada execução de validação, portanto, tome cuidado ao usar variáveis ​​de instância dentro dele.

Se o seu validador for complexo o suficiente para que você queira variáveis ​​de instância, você pode facilmente usar um objeto Ruby simples e antigo:

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "This person is evil"
    end
  end

  # ...
end
```

Abordaremos as validações personalizadas mais tarde.

## Opções comuns de validação

Existem diversas opções comuns suportadas pelos validadores que acabamos de examinar, vamos examinar algumas delas agora!

![Aviso Opções de Validação](/imagens/acitive_record_validations14.JPG)

Ao usar qualquer um dos métodos de validação que acabamos de mencionar, também há uma lista de opções comuns compartilhadas com validadores. Vamos cobrir isso agora!

- `:allow_nil`: Ignora a validação se o atributo for nil.
- `:allow_blank`: Ignora a validação se o atributo estiver em branco.
- `:message`: especifique uma mensagem de erro personalizada.
- `:on`: Especifique os contextos onde esta validação está ativa.
- `:strict`: gera uma exceção quando a validação falha.
- `:if` e `:unless` : Especifique quando a validação deve ou não ocorrer.


### :allow_nil

A opção `:allow_nil` ignora a validação quando o valor que está sendo validado é nil.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```
```bash
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

Para opções completas para o argumento da mensagem, consulte a documentação da mensagem .

### :allow_blank

A opção `:allow_blank` é semelhante à opção `:allow_nil`. Esta opção permitirá que a validação passe se o valor do atributo for `blank?`, como `nil` ou uma string vazia, por exemplo.

```RUBY
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```
```bash
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### :message

Como você já viu, a opção `:message` permite especificar a mensagem que será adicionada à coleção `errors` quando a validação falhar. Quando esta opção não for utilizada, o Active Record utilizará a respectiva mensagem de erro padrão para cada auxiliar de validação.

A opção `:message` aceita a `String` ou `Proc` como valor.

Opcionalmente, um valor `:message` `String`  pode conter qualquer um / todos entre `%{value}`, `%{attribute}` e `%{model}` que será substituído dinamicamente quando a validação falhar. Essa substituição é feita usando a gema i18n, e os espaços reservados devem corresponder exatamente, não são permitidos espaços.

```ruby
class Person < ApplicationRecord
  # Hard-coded message
  validates :name, presence: { message: "must be given please" }

  # Message with dynamic attribute value. %{value} will be replaced
  # with the actual value of the attribute. %{attribute} and %{model}
  # are also available.
  validates :age, numericality: { message: "%{value} seems wrong" }
end
```

Um valor `:message` `Proc` recebe dois argumentos: o objeto que está sendo validado e um hash com `:model`, `:attribute` e `:value` pares de valores-chave.

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = person object being validated
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}, #{data[:value]} is already taken."
      end
    }
end
```

### :on

A opção `:on` permite especificar quando a validação deve acontecer. O comportamento padrão para todos os auxiliares de validação integrados é ser executado ao salvar (tanto ao criar um novo registro quanto ao atualizá-lo). Se quiser alterá-lo, você pode usar `on: :create` para executar a validação somente quando um novo registro for criado ou `on: :update` para executar a validação somente quando um registro for atualizado.

```ruby
class Person < ApplicationRecord
  # it will be possible to update email with a duplicated value
  validates :email, uniqueness: true, on: :create

  # it will be possible to create the record with a non-numerical age
  validates :age, numericality: true, on: :update

  # the default (validates on both create and update)
  validates :name, presence: true
end
```

Você também pode usar `on:` para definir contextos personalizados. Os contextos personalizados precisam ser acionados explicitamente, passando o nome do contexto para `valid?`, `invalid?` ou `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```bash
irb> person = Person.new(age: 'thirty-three')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"]}
```

`person.valid?(:account_setup)` executa ambas as validações sem salvar o modelo. `person.save(context: :account_setup)` valida `person` no contexto `account_setup` antes de salvar.

Passar uma série de símbolos também é aceitável.

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```bash
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["can't be blank"]}
```

Quando acionadas por um contexto explícito, as validações são executadas para esse contexto, bem como quaisquer validações sem contexto.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```bash
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"], :name=>["can't be blank"]}
```

Abordaremos mais casos de uso `on:` no guia de retornos de chamada.

## Validações rigorosas

Você também pode especificar validações para serem rigorosas e aumentar `ActiveModel::StrictValidationFailed` quando o objeto for inválido.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```bash
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: Name can't be blank
``` 

Também existe a capacidade de passar uma exceção personalizada para a opção `:strict`.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```bash
irb> Person.new.valid?
TokenGenerationException: Token can't be blank
```

## Validação Condicional

Às vezes fará sentido validar um objeto somente quando um determinado predicado for satisfeito. Você pode fazer isso usando as opções `:if` e `:unless`, que podem receber um símbolo, um Procou um Array. Você pode usar a opção `:if` quando quiser especificar quando a validação deve acontecer. Alternativamente, se quiser especificar quando a validação não deve acontecer, você pode usar a opção `:unless`.

### Usando um símbolo com `:if` e `:unless`

Você pode associar as opções `:if` e `:unless` a um símbolo correspondente ao nome de um método que será chamado logo antes da validação acontecer. Esta é a opção mais comumente usada.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Usando um `Proc` com `:if` e `:unless`

É possível associar `:if` e `:unless` a um objeto `Proc` que será chamado. Usar um objeto `Proc` permite escrever uma condição embutida em vez de um método separado. Esta opção é mais adequada para one-liners.


```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

Como `lambda` é um tipo de `Proc`, também pode ser usado para escrever condições in-line aproveitando a sintaxe abreviada.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Agrupando Validações Condicionais

Às vezes é útil ter múltiplas validações usando uma condição. Isso pode ser facilmente alcançado usando `with_options`.

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

Todas as validações dentro do bloco `with_options` terão passado automaticamente na condição `if: :is_admin?`

### Combinando Condições de Validação

Por outro lado, quando múltiplas condições definem se uma validação deve ou não acontecer, um `Array` pode ser usado. Além disso, você pode aplicar ambos `:if` à `:unless` mesma validação.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

A validação só é executada quando todas as condições `:if` e nenhuma das condições `:unless` são avaliadas como true.

## Realizando validações personalizadas

Quando os auxiliares de validação integrados não são suficientes para suas necessidades, você pode escrever seus próprios validadores ou métodos de validação conforme preferir.

### Validadores Personalizados

Validadores personalizados são classes que herdam de `ActiveModel::Validator`. Essas classes devem implementar o método `validate` que recebe um registro como argumento e realiza a validação nele. O validador personalizado é chamado usando o método `validates_with`.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Provide a name starting with X, please!"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

A maneira mais fácil de adicionar validadores personalizados para validar atributos individuais é com o conveniente arquivo `ActiveModel::EachValidator`. Nesse caso, a classe validadora customizada deve implementar um método `validate_each` que recebe três argumentos: registro, atributo e valor. Correspondem à instância, ao atributo a ser validado e ao valor do atributo na instância passada.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

Conforme mostrado no exemplo, você também pode combinar validações padrão com seus próprios validadores personalizados.


### Métodos Personalizados

Você também pode criar métodos que verifiquem o estado dos seus modelos e adicionem erros à coleção `errors` quando eles forem inválidos. Você deve então registrar esses métodos usando o método `validate` de classe, passando os símbolos para os nomes dos métodos de validação.

Você pode passar mais de um símbolo para cada método de classe e as respectivas validações serão executadas na mesma ordem em que foram registradas.

O método `valid?` verificará se a coleção `errors` está vazia, portanto, seus métodos de validação personalizados deverão adicionar erros a ela quando você desejar que a validação falhe:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end
```

Por padrão, essas validações serão executadas sempre que você chamar `valid?` ou salvar o objeto. Mas também é possível controlar quando executar essas validações personalizadas, dando uma opção `:on` ao método `validate`, com: `:create` ou `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```

Consulte a seção acima para obter mais detalhes sobre `:on`.

### Validadores de listagem

Se você quiser descobrir todos os validadores para um determinado objeto, procure por `validators`.

Por exemplo, se tivermos o seguinte modelo usando um validador personalizado e um validador integrado:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

Agora podemos utilizar `validators` no modelo “Pessoa” para listar todos os validadores, ou até mesmo verificar um campo específico utilizando `validators_on`.

```bash
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```

## Trabalhando com Erros de Validação

