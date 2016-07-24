# frozen_string_literal: true
# :nodoc:
class Entry < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by, against: [:body, :title, :user]

  mount_uploader :entry_header, EntryHeaderUploader

  validates :title, :body, presence: true

  belongs_to :user
  belongs_to :journal
  has_many :sentiments, dependent: :delete_all
  has_many :emotions, dependent: :delete_all

  after_save :perform_analysis

  def self.all_by_user_and_journal(user, journal)
    return [] unless user || journal
    Entry.where(user: user, journal: journal).order(updated_at: :desc)
  end

  def self.new_for_journal(journal, user = nil)
    owner_id = user.nil? ? journal.user.id : user.id
    Entry.new(journal_id: journal.id, user_id: owner_id)
  end

  def self.find_by_user(id, journal_id, user)
    Entry.find_by(id: id, journal_id: journal_id, user_id: user.id)
  end

  # This method uses upddate_column instead of update
  # to not trigger the callbacks causing a call to
  # Indico API
  def set_favorite
    update_column(:favorite, true)
  end

  # see #set_favorite
  def unfavorite
    update_column(:favorite, false)
  end

  def perform_analysis
    IndicoEmotionJob.perform_later(self)
    IndicoSentimentJob.perform_later(self)
  end
end
