# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Remindem.
#
# Remindem is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Remindem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Remindem.  If not, see <http://www.gnu.org/licenses/>.

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable

  # WARNING if this is removed, nuntium channels must be updated in order to reflect changes in email!
  validate do
    if !self.new_record? && self.email_changed?
      errors.add(:email, "can't be changed")
    end
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :schedules, :dependent => :destroy

  has_one :channel, :dependent => :destroy

  has_many :identities, dependent: :destroy

  serialize :features, Hash

  after_save :telemetry_track_activity

  def register_channel(code)
    raise Nuntium::Exception.new("There were problems creating the channel", "Ticket code" => "Mustn't be blank") if code.blank?
    remove_old_channel
    new_channel_info = create_nuntium_channel_for code
    channel = self.build_channel :name => new_channel_info["name"], :address => new_channel_info["address"]
    channel.save!
  end

  def build_message(to, body)
    { :from => "remindem".with_protocol, :to => to, :body => body, :'x-remindem-user' => self.email }
  end

  def remove_old_channel
    channel = Channel.find_by_user_id(self.id)
    channel.destroy  unless channel.nil?
  end

  def create_nuntium_channel_for code
    Nuntium.new_from_config.create_channel({
      :name => self.email.to_channel_name,
      :ticket_code => code,
      :ticket_message => "This gateway will be used for reminders written by #{self.email}",
      :at_rules => [{
        'matchings' => [],
        'actions' => [{ 'property' => 'x-remindem-user', 'value' => self.email }],
        'stop' => false}],
      :restrictions => [{ 'name' => 'x-remindem-user', 'value' => self.email }],
      :kind => 'qst_server',
      :protocol => 'sms',
      :direction => 'bidirectional',
      :configuration => { :password => SecureRandom.base64(6) },
      :enabled => true
    })
  end

  def feature_enabled?(feature)
    features && features[feature.to_s]
  end

  def enable_feature!(feature)
    self.features ||= {}
    self.features[feature.to_s] = true
    save!
  end

  def disable_feature!(feature)
    self.features ||= {}
    self.features[feature.to_s] = false
    save!
  end

  def telemetry_track_activity
    InsteddTelemetry.timespan_since_creation_update(:account_lifespan, {account_id: self.id}, self)
  end
end
