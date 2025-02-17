## Task
Необходимо реализовать класс контроллера поддерживающий идемпотентность и защиту от гонки процессов. На вход подаются два необязательных параметра: ключ идемпотентности и одно натуральное число. На выходе контроллер должен вернуть сумму поданных на вход натуральных чисел когда-либо.
Хранилищем данных для получения суммы натуральных чисел должен быть PG, для работы с идемпотентностью и защитой от гонки процессов можно использовать как Redis, так и PG. Время жизни Redis ключей должно быть ограничено.
Нельзя подключать готовые библиотеки, реализующие функционал идемпотентности или защиты от гонки процессов, если таковые имеются. Нельзя использовать процедуры в PG.
Контроллер работает под любым веб-сервером запущенным под несколько инстансов.
Код должен быть покрыт тестами.

## Setup
```
bin/rails db:create
```

## Running
`rails s`

## Testing
Specs
```
bundle exec rspec
```
Concurrency
```
bundle exec rake concurrency:execute_test
```
