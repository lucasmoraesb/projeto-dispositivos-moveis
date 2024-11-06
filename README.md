Projeto Mobile

Este repositório contém um aplicativo mobile desenvolvido em Flutter para ajudar no gerenciamento de tarefas domésticas de forma prática e organizada.

## Funcionalidades

- Adição e remoção de tarefas do dia-a-dia.
- Visualização de tarefas e conclusão de tarefas.
- Organização por data e calendário.
- Favoritar tarefas com o status incluso.

## Tecnologias Utilizadas

- Flutter : Framework para desenvolvimento mobile.
- table_calendar : Componente de calendário para organização das tarefas.
- Intl : Suporte a internacionalização.
- Provider : Gerenciamento de estado.

### Desenvolvedores

- Gabriel Camlofski Horst
- Lucas Moraes Borges
- Gustavo Henrique Amaral Costa

### Instalação

```hc1
apt-get
flutter apt get
```

- Baixa todas as dependências declaradas no arquivo `pubspec.yaml`.

```hc1
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  provider: ^5.0.0
  table_calendar: ^3.1.2
  intl: ^0.19.0
```

- As dependências do arquivo `pubspec.yaml`.

### Desenvolvimento da Equipe

- Gabriel Camlofski Horst : CRUD das tarefas e UI delas.
- Lucas Moraes Borges : Calendário dinâmico com os dias de tarefas.
- Gustavo Henrique Amaral : Estrutura do projeto, manutenção e os merges.

### Bugs - Erros

- SetState estático, sem o uso total do provider, algumas partes usamos provider.
- Falta de uma indicação no calendário de tarefas.
- Quando conclui uma tarefa ele não atualiza direto na tela, problema no SetState.

### Funcionalidades faltantes

- "Alguma coisa a mais" na parte do calendário.
- Edição de data e nome da tarefa.
