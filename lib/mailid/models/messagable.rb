module Mailid
  module Models
    module Messagable 
      extend ActiveSupport::Concern

      included do
        include Mailid::Messaging
        has_and_belongs_to_many :conversations, class_name: 'Conversation', inverse_of: :users
        has_many :receipts
        has_many :archived_conversations
      end

      def inbox
        conversations_by('inbox')
      end

      def sentbox
        conversations_by('sentbox')
      end

      def archived
        ar_conv = ArchivedConversation.archived_for(self)
        ar_conv.any? ? ar_conv.map(&:conversation) : []
      end

      def conversations_by(message_type)
        tidy_conversations(conversations.select { |conv| conv.last_message.receipts.where(message_type: message_type, user: self).any? })
      end

      def no_archived(conversations)
        conversations.select { |conversation| !is_archived?(conversation) }
      end

      def no_trashed(conversations)
        conversations.select { |conversation| !is_trashed?(conversation) }
      end

      def tidy_conversations(conversations)
        conversations = no_archived(conversations)
        no_trashed(conversations)
      end

      def mark_as_archived(conversation)
        ArchivedConversation.create(user: self, conversation: conversation) unless is_archived?(conversation)
      end

      def unarchive(conversation)
        ArchivedConversation.where(user: self, conversation: conversation).destroy
      end

      def is_archived?(conversation)
        archived.include?(conversation)
      end

      def add_to_trash(conversation)
        TrashedConversation.create(user: self, conversation: conversation) unless is_trashed?(conversation)
      end

      def untrash(conversation)
        TrashedConversation.where(user: self, conversation: conversation).destroy
      end

      def is_trashed?(conversation)
        TrashedConversation.trashed_for(self).map(&:conversation).include?(conversation)
      end

      def unread_conversations
        inbox.select { |c| !c.read? self }
      end
    end
  end
end
