require 'spec_helper'

describe ArchivedConversation do
  context 'associations' do
    it { should belong_to(:conversation) }
    it { should belong_to(:user) }
  end
end
