## Projeto Mobile - Tarefas domésticas

### Entrega 2 - Banco de dados, Login

Este repositório contém um aplicativo mobile desenvolvido em Flutter para ajudar no gerenciamento de tarefas domésticas de forma prática e organizada.

## Funcionalidades

- Adição e remoção de tarefas do dia-a-dia.
- Visualização de tarefas e conclusão de tarefas.
- Organização por data e calendário.
- Entrada e saída de uma casa.
- Adição de tarefas relacionadas aos usuários da casa.

## Tecnologias Utilizadas

- Flutter : Framework para desenvolvimento mobile.
- table_calendar : Componente de calendário para organização das tarefas.
- Intl : Suporte a internacionalização.
- Provider : Gerenciamento de estado.
- Firebase : Banco de dados online para as operações de usuários e casas com as tarefas.

### Desenvolvedores

- Gabriel Camlofski Horst.
- Lucas de Moraes Borges.
- Gustavo Henrique Amaral Costa.

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
  firebase_core: "^3.8.0"
  firebase_auth: "^5.3.3"
  cloud_firestore: ^5.5.1
```

- As dependências do arquivo `pubspec.yaml`.

### Desenvolvimento da Equipe

- Gabriel Camlofski Horst : Desenvolvimento das entregas, correção do calendário e implementações.
- Lucas de Moraes Borges : Desenvolvimento das entregas, banco de dados e implementação do banco no projeto.
- Gustavo Henrique Amaral : Estrutura inicial do projeto e das entregas.

### Bugs - Erros

- Seleção de tarefa sem a mudança do ícone.

### Funcionalidades faltantes

- Implementação de um usuario id para o banco de dados.
