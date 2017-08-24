# == Schema Information
#
# Table name: series
#
#  id              :integer          not null, primary key
#  course_id       :integer
#  name            :string(255)
#  description     :text(65535)
#  visibility      :integer
#  order           :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  deadline        :datetime
#  access_token    :string(255)
#  indianio_token  :string(255)
#

require 'csv'

class Series < ApplicationRecord
  enum visibility: %i[open hidden closed]

  belongs_to :course
  has_many :series_memberships, dependent: :destroy
  has_many :exercises, through: :series_memberships

  validates :course, presence: true
  validates :name, presence: true

  before_save :set_tokens

  default_scope { order(created_at: :desc) }

  def deadline?
    deadline.present?
  end

  def zip_solutions(user, with_info: false)
    filename = "#{name.parameterize}-#{user.full_name.parameterize}.zip"
    stringio = Zip::OutputStream.write_buffer do |zio|
      info = CSV.generate(force_quotes: true) do |csv|
        csv << %w[filename status submission_id name]
        exercises.each do |ex|
          submission = ex.last_submission(user, deadline, course)
          # write the submission
          zio.put_next_entry(ex.file_name)
          zio.write submission&.code
          # write some extra information to the csv
          csv << [ex.file_name, submission&.status, submission&.id, ex.name]
        end
      end
      if with_info
        zio.put_next_entry('info.csv')
        zio.write info
      end
    end
    stringio.rewind
    zip_data = stringio.sysread
    { filename: filename, data: zip_data }
  end

  private

  def set_tokens
    if !hidden?
      self.access_token = nil
    elsif access_token.blank?
      self.access_token = SecureRandom.urlsafe_base64(6)
    end
    self.indianio_token = SecureRandom.urlsafe_base64(16) if indianio_token.blank?
  end
end
