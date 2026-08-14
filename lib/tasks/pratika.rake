# frozen_string_literal: true

namespace :pratika do
  desc 'Configura os departamentos, atributos customizados e respostas rápidas para a Prátika Facilities'
  task :setup_facilities, [:account_id] => :environment do |_t, args|
    account_id = args[:account_id] || Account.first&.id
    if account_id.blank?
      puts '⚠️ Nenhuma conta encontrada. Crie uma conta ou informe o account_id: rake pratika:setup_facilities[ID]'
      next
    end

    account = Account.find(account_id)
    puts "🚀 Configurando Prátika Facilities para a Conta: #{account.name} (ID: #{account.id})"

    # 1. Criação das Equipes / Departamentos
    facilities_teams = [
      { name: 'Limpeza e Conservação', description: 'Atendimento operacional para postos de limpeza, reposição de insumos e vistorias.' },
      { name: 'Portaria e Controle', description: 'Atendimento para controle de acesso, escalas de porteiros e ocorrências.' },
      { name: 'Jardinagem e Paisagismo', description: 'Gestão de áreas verdes, cronograma de podas e manutenção.' },
      { name: 'Recepção e Serviços de Apoio', description: 'Suporte a recepcionistas, copeiras e mensageria.' },
      { name: 'Financeiro e Faturamento', description: '2ª via de boletos, notas fiscais, medições e cobrança (Acesso Restrito).' },
      { name: 'Comercial e Novos Contratos', description: 'Atendimento a novos clientes, propostas comerciais e orçamentos.' }
    ]

    facilities_teams.each do |team_data|
      team = account.teams.find_or_initialize_by(name: team_data[:name].downcase)
      team.description = team_data[:description]
      team.allow_auto_assign = true
      team.save!
      puts "  ✅ Equipe configurada: #{team_data[:name]}"
    end

    # 2. Atributos Customizados para Conversas de Facilities
    custom_attributes = [
      {
        attribute_display_name: 'Posto de Trabalho / Unidade',
        attribute_key: 'posto_trabalho',
        attribute_display_type: 'text',
        attribute_model: 'conversation_attribute',
        attribute_description: 'Nome da empresa, condomínio ou unidade atendida'
      },
      {
        attribute_display_name: 'Número do Contrato',
        attribute_key: 'numero_contrato',
        attribute_display_type: 'text',
        attribute_model: 'conversation_attribute',
        attribute_description: 'Identificador do contrato do cliente na Prátika'
      },
      {
        attribute_display_name: 'Tipo de Ocorrência',
        attribute_key: 'tipo_ocorrencia',
        attribute_display_type: 'list',
        attribute_values: ['Dúvida Operacional', 'Reposição de Insumos', 'Solicitação de Cobertura / Falta', 'Elogio / Sugestão', 'Reclamação', 'Financeiro'],
        attribute_model: 'conversation_attribute',
        attribute_description: 'Classificação do chamado'
      },
      {
        attribute_display_name: 'Nível de Urgência',
        attribute_key: 'nivel_urgencia',
        attribute_display_type: 'list',
        attribute_values: ['Baixa', 'Média', 'Alta (Imediata)', 'Emergencial'],
        attribute_model: 'conversation_attribute',
        attribute_description: 'Prioridade de atendimento conforme SLA'
      }
    ]

    custom_attributes.each do |attr_data|
      attr_def = account.custom_attribute_definitions.find_or_initialize_by(
        attribute_key: attr_data[:attribute_key],
        attribute_model: attr_data[:attribute_model]
      )
      attr_def.attribute_display_name = attr_data[:attribute_display_name]
      attr_def.attribute_display_type = attr_data[:attribute_display_type]
      attr_def.attribute_description = attr_data[:attribute_description]
      attr_def.attribute_values = attr_data[:attribute_values] if attr_data[:attribute_values]
      attr_def.save!
      puts "  ✅ Atributo customizado: #{attr_data[:attribute_display_name]}"
    end

    # 3. Respostas Rápidas Padronizadas (Canned Responses)
    canned_responses = [
      {
        short_code: 'boasvindas',
        content: "Olá! Obrigado por entrar em contato com a *Prátika Facilities* — O terceiro que coloca você em primeiro!\nComo podemos ajudar você hoje?"
      },
      {
        short_code: 'financeiro',
        content: "Olá! Você está no setor *Financeiro da Prátika Facilities*.\nPor favor, informe o CNPJ da empresa e o número do contrato para localizarmos sua fatura ou 2ª via de boleto."
      },
      {
        short_code: 'limpeza_insumos',
        content: "Recebemos sua solicitação de reposição de insumos. Nossa equipe de *Logístika* já foi acionada e o prazo padrão de entrega no seu posto é de até 24 horas úteis."
      },
      {
        short_code: 'cobertura_reserva',
        content: "Informamos que nossa equipe de *Reserva Técnica* já foi notificada para assegurar a cobertura do posto de trabalho sem qualquer descontinuidade dos serviços."
      },
      {
        short_code: 'encerramento',
        content: "Agradecemos o seu contato com a Prátika Facilities! Caso precise de qualquer outro suporte, estamos sempre à disposição. Tenha um excelente dia!"
      }
    ]

    canned_responses.each do |cr|
      canned = account.canned_responses.find_or_initialize_by(short_code: cr[:short_code])
      canned.content = cr[:content]
      canned.save!
      puts "  ✅ Resposta Rápida: /#{cr[:short_code]}"
    end

    puts "\n🎉 Estrutura da Prátika Facilities implantada com sucesso na conta #{account.name}!"
  end

  desc 'Aplica e atualiza o branding global da Prátika Facilities no banco de dados'
  task set_branding: :environment do
    configs = {
      'INSTALLATION_NAME' => 'Prátika Facilities',
      'BRAND_NAME' => 'Prátika Facilities',
      'BRAND_URL' => 'https://pratika.com.br',
      'WIDGET_BRAND_URL' => 'https://pratika.com.br',
      'LOGO' => '/brand-assets/logo.svg',
      'LOGO_DARK' => '/brand-assets/logo_dark.svg',
      'LOGO_THUMBNAIL' => '/brand-assets/logo_thumbnail.svg',
      'TERMS_URL' => 'https://pratika.com.br/privacidade',
      'PRIVACY_URL' => 'https://pratika.com.br/privacidade',
      'DISPLAY_MANIFEST' => false
    }

    configs.each do |name, val|
      config = InstallationConfig.find_or_initialize_by(name: name)
      config.value = val
      config.locked = false
      config.save!
      puts "  ✅ Configuração de Marca: #{name} -> #{val}"
    end

    GlobalConfig.clear_cache
    puts "\n✨ Branding global da Prátika Facilities atualizado no banco de dados!"
  end
end
