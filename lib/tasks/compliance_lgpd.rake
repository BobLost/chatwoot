# frozen_string_literal: true

require 'csv'

namespace :compliance do
  desc 'Exporta relatório completo de conversas para auditoria, Compliance e LGPD (CSV/JSON)'
  task :export_conversations, [:account_id, :days_back, :output_format] => :environment do |_t, args|
    account_id = args[:account_id] || Account.first&.id
    days_back = (args[:days_back] || 30).to_i
    output_format = args[:output_format] || 'csv'

    account = Account.find(account_id)
    start_date = days_back.days.ago.beginning_of_day
    end_date = Time.current

    puts "🛡️ Iniciando Exportação de Compliance / LGPD para Conta: #{account.name} (ID: #{account.id})"
    puts "📅 Período: #{start_date.strftime('%d/%m/%Y %H:%M')} até #{end_date.strftime('%d/%m/%Y %H:%M')}"

    conversations = account.conversations
                           .where('created_at >= ? AND created_at <= ?', start_date, end_date)
                           .includes(:contact, :assignee, :inbox, :team, :messages)
                           .order(created_at: :asc)

    puts "📊 Total de conversas localizadas: #{conversations.count}"

    export_dir = Rails.root.join('storage', 'compliance_reports')
    FileUtils.mkdir_p(export_dir)

    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "relatorio_compliance_lgpd_conta_#{account.id}_#{timestamp}.#{output_format}"
    file_path = export_dir.join(filename)

    if output_format == 'json'
      data = conversations.map do |conv|
        {
          id: conv.id,
          display_id: conv.display_id,
          created_at: conv.created_at.iso8601,
          updated_at: conv.updated_at.iso8601,
          channel: conv.inbox&.channel_type,
          inbox_name: conv.inbox&.name,
          team_name: conv.team&.name,
          agent_name: conv.assignee&.name,
          agent_email: conv.assignee&.email,
          contact_name: conv.contact&.name,
          contact_phone: conv.contact&.phone_number,
          contact_email: conv.contact&.email,
          status: conv.status,
          custom_attributes: conv.custom_attributes,
          messages_count: conv.messages.count,
          transcript: conv.messages.map do |msg|
            {
              id: msg.id,
              sender_type: msg.sender_type,
              sender_name: msg.sender&.try(:name) || (msg.message_type == 'incoming' ? conv.contact&.name : 'Sistema'),
              message_type: msg.message_type,
              content: msg.content,
              created_at: msg.created_at.iso8601,
              private: msg.private
            }
          end
        }
      end

      File.write(file_path, JSON.pretty_generate(data))
    else
      headers = [
        'ID Conversa', 'Data Criação', 'Canal / Caixa', 'Equipe / Depto',
        'Atendente', 'Contato / Cliente', 'Telefone', 'E-mail',
        'Status', 'Posto de Trabalho', 'Nº Contrato', 'Tipo Ocorrência',
        'Nível Urgência', 'Qtd Mensagens', 'Transcrição Completa das Mensagens'
      ]

      CSV.open(file_path, 'wb', col_sep: ';', encoding: 'UTF-8') do |csv|
        # UTF-8 BOM for Excel compatibility
        csv.to_io.write "\xEF\xBB\xBF"
        csv << headers

        conversations.find_each(batch_size: 100) do |conv|
          custom_attrs = conv.custom_attributes || {}
          
          # Formata a transcrição completa das mensagens
          transcript = conv.messages.order(created_at: :asc).map do |m|
            sender = m.sender&.try(:name) || (m.message_type == 'incoming' ? conv.contact&.name : 'Sistema')
            prefix = m.private ? '[NOTA PRIVADA]' : ''
            "[#{m.created_at.strftime('%d/%m/%Y %H:%M:%S')}] #{prefix}#{sender}: #{m.content}"
          end.join("\n")

          csv << [
            conv.display_id,
            conv.created_at.strftime('%d/%m/%Y %H:%M:%S'),
            conv.inbox&.name,
            conv.team&.name || 'Sem Equipe',
            conv.assignee&.name || 'Não Atribuído',
            conv.contact&.name || 'Desconhecido',
            conv.contact&.phone_number,
            conv.contact&.email,
            conv.status,
            custom_attrs['posto_trabalho'],
            custom_attrs['numero_contrato'],
            custom_attrs['tipo_ocorrencia'],
            custom_attrs['nivel_urgencia'],
            conv.messages.count,
            transcript
          ]
        end
      end
    end

    puts "✅ Relatório de Compliance gerado com sucesso!"
    puts "📁 Caminho do arquivo: #{file_path}"
    puts "💡 Use este arquivo para auditorias ISO 9001, atendimento a requisições de titulares LGPD e comprovação contratual."
  end
end
