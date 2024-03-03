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

