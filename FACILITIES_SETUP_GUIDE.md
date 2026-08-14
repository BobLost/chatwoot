# Guia de Configuração e Permissões: Prátika Facilities

Este guia documenta o funcionamento da arquitetura de departamentos, isolamento de mensagens e regras de permissão para a **Prátika Facilities**.

---

## 1. Departamentos e Equipes Configuradas

O sistema foi estruturado com as 6 frentes operacionais e administrativas da Prátika:

1. **🧹 Limpeza e Conservação**: Demandas de insumos, vistorias, checklists e ocorrências de postos de trabalho.
2. **🛡️ Portaria e Controle**: Controle de acessos, ocorrências de portaria, escalas e rondas.
3. **🌿 Jardinagem e Paisagismo**: Cronogramas de poda, manutenção de áreas verdes e adubação.
4. **🛎️ Recepção e Apoio**: Demandas de recepcionistas, copeiras e mensageria.
5. **💳 Financeiro e Faturamento (🔒 Área Isolada)**: 2ª via de boletos, faturas, notas fiscais e cobranças.
6. **🤝 Comercial e Novos Contratos**: Qualificação de novos leads e propostas de facilities.

---

## 2. Isolamento de Mensagens e Privacidade (Como Funciona)

### A. Regra do Departamento Financeiro (Privacidade Total)
* **Caixa de Entrada Exclusiva**: Criada uma Inbox específica (ex: *WhatsApp Financeiro* ou canal interno).
* **Vínculo Restrito**: Somente os agentes do time de Financeiro são adicionados como membros dessa Inbox.
* **Resultado**: Atendentes da Limpeza, Portaria ou Recepção **NÃO têm acesso** nem visualizam as conversas do Financeiro na barra lateral.

### B. Regra "Ninguém vê conversas atribuídas a outros"
* No Chatwoot, os atendentes operacionais comuns devem ser cadastrados com a função de **Agente (Agent)** e não Administrador.
* Na visualização diária, os agentes utilizam a aba **"Minhas" (Mine)** na lista de conversas, que filtra exclusivamente as conversas atribuídas a eles.
* Para restringir totalmente a visão de conversas não atribuídas a um agente específico, utiliza-se a política de times onde cada agente opera dentro do seu escopo de fila.

### C. Notas Privadas (Comunicação Interna entre Supervisores)
* Caso um supervisor precise encaminhar uma conversa da Portaria para o Financeiro com informações confidenciais, ele utiliza a aba **"Nota Privada"** dentro da conversa (fundo amarelo).
* As notas privadas nunca são enviadas para o cliente (WhatsApp/Chat) e são visíveis apenas para os atendentes autorizados.

---

## 3. Automação e Comandos Rápidos

Para aplicar toda a estrutura de equipes, atributos customizados e respostas rápidas na sua conta, basta rodar o comando:

```bash
bundle exec rails pratika:setup_facilities
```

Ou especificando o ID da conta:
```bash
bundle exec rails "pratika:setup_facilities[1]"
```

E para recarregar o branding oficial no banco de dados:
```bash
bundle exec rails pratika:set_branding
```

---

## 4. Respostas Rápidas Inclusas (Atalhos no Atendimento)

* `/boasvindas`: Saudação institucional da Prátika com slogan *"O terceiro que coloca você em primeiro!"*.
* `/financeiro`: Solicitação de CNPJ e contrato para emissão de 2ª via.
* `/limpeza_insumos`: Confirmação de acionamento do setor de *Logístika* (prazo 24h).
* `/cobertura_reserva`: Informação de acionamento da equipe de *Reserva Técnica*.
* `/encerramento`: Mensagem de encerramento amigável.
