# Guia de Atualização Segura: Chatwoot Prátika Facilities

Este guia documenta o procedimento padronizado para atualizar o Chatwoot para novas versões oficiais **sem perder o layout, cores, logos ou regras da Prátika Facilities**.

---

## Estrutura do Repositório

* **`upstream`**: Repositório oficial (`https://github.com/chatwoot/chatwoot.git`).
* **`origin`**: Seu repositório fork (`https://github.com/BobLost/chatwoot.git`).
* **`pratika-facilities`**: Sua branch de produção onde estão todas as customizações da Prátika.

---

## Procedimento de Atualização (Passo a Passo)

### 1. Baixar as últimas atualizações do Chatwoot Oficial
No terminal da sua máquina:

```bash
# 1. Garanta que está na branch da Prátika
git checkout pratika-facilities

# 2. Busque todas as novidades do Chatwoot oficial
git fetch upstream

# 3. Faça o merge da versão mais recente (ou de uma tag específica, ex: v3.18.0)
git merge upstream/master
```

### 2. Validação e Resolução de Conflitos (Se houver)
Como todas as nossas customizações de estilo estão isoladas em `app/javascript/dashboard/assets/scss/_pratika.scss` e os logos em `public/brand-assets/`, a chance de conflito é mínima.

Se o Git indicar conflito em algum arquivo compartilhado (como `installation_config.yml` ou `app.scss`):
* Abra o arquivo, mantenha as linhas da Prátika e salve.
* Execute:
  ```bash
  git add .
  git commit -m "chore(upgrade): sync with upstream chatwoot release"
  ```

### 3. Enviar para o GitHub (Disparar o Build Automático)
Ao enviar as alterações para a branch `pratika-facilities`:

```bash
git push origin pratika-facilities
```

O **GitHub Actions** (`publish_pratika_docker.yml`) entrará em ação automaticamente:
1. Irá compilar a nova versão do Chatwoot com os temas e logos da Prátika.
2. Irá gerar e publicar a nova imagem no GitHub Container Registry: `ghcr.io/boblost/chatwoot:pratika-latest`.

### 4. Atualizar o Servidor em Produção (Deploy em 1 Minuto)
No seu servidor VPS / Produção:

```bash
# 1. Baixar a nova imagem compilada
docker compose -f docker-compose.pratika.yml pull

# 2. Rodar as migrações de banco de dados (se houver novas tabelas)
docker compose -f docker-compose.pratika.yml run --rm rails bundle exec rails db:chatwoot_prepare

# 3. Reiniciar os containers com a nova versão
docker compose -f docker-compose.pratika.yml up -d
```

Pronto! Seu sistema estará 100% atualizado com os novos recursos do Chatwoot oficial e mantendo integralmente a identidade e regras da Prátika Facilities.
