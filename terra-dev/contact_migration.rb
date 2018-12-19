# This is the UserSocial migration
# It cleans up orphaned, duplicate, manually "deactivated", etc. UserSocial contacts
# and sets makes a best-guess at which contacts to set as primary.

# Feel free to read through this, though it's pretty involved.
# You also shouldn't need to run this again.

# The entrypoint is: `migrate_user_contacts!`


module Enumerable
  def duplicates
    self.group_by(&:itself).select{|_,v| v.size>1}.keys
  end
  alias_method :reverse_uniq, :duplicates
end


class UserContact
  attr_reader :identifier, :network, :cleaned
  attr_accessor :user_id

  def initialize(identifier, user_id=nil)
    @identifier = identifier.to_s
    @user_id    = user_id
    update_network!
    @cleaned = false
  end

  def identifier=(new_identifier)
    return if @identifier == new_identifier
    @identifier = new_identifier
    update_network!
    @cleaned = false
  end

  def update_network!
    @network = :phone  if @identifier.match(/^\d++$/).present?
    @network = :email  if @identifier.match(/^.+@.+$/).present?
    @network
  end

  def email?   ; (@network == :email) ; end
  def phone?   ; (@network == :phone) ; end
  def cleaned? ;  @cleaned            ; end

  def clean!
    return @identifier  unless @network == :email

    # Clean up "deactivated" emails
    original = @identifier.dup

    # mailbox@domain.tldxxxzzzxyz
    @identifier.gsub! /[xyz]{3,}$/, ''

    # mailbox@domainxxxyyyxyz.tld
    @identifier.gsub! /^([^@]+)(@.+?)[xyz]{3,}(\..+)$/, '\1\2\3'

    # mailbox@xyzdomain.tld
    #  | there's an @xyzdrinkboard.com entry, whose domain is invalid.
    #  | there's also @xxxgmail.com emails, but that domain actually is valid!
    @identifier.gsub! /^([^@]+@)xyz(drinkboard\..+)$/, '\1\2\3'

    # xxxmailboxxxx@domain.tld
    #  | These look to be part of a (manual) legacy means of "disabling" emails
    #  | Example: "xxxqaxxx@drinkboard.comxxx"  -- the email probably wasn't "xxxqaxxx@drinkboard.com" originally.
    #  | There is also one instance of mismatched x's: "xxxchavezlaurenxx@yahoo.comxxx", indicating this was likely done manually.
    @identifier.gsub! /^xxx(.+?)[zx]{2,3}(@.++)/, '\1\2'

    @cleaned ||= (@identifier != original)
  end
end




def missing_usersocial_contacts(silent:false)
  # Instances where a user's "network columns" (phone, email) are not included within their UserSocials
  # Returns an array of UserContacts

  missing = []
  User.all.each do |user|
    [:phone, :email].each do |network|
      next if user.send(network).blank?
      next if UserSocial.unscoped.where(user:user, type_of:network).pluck(:identifier).map(&:downcase).include?(user.send(network).downcase)
      printf '.'  unless silent
      missing << UserContact.new(user.send(network).downcase, user.id)
    end
  end
  printf "\n"  unless silent
  missing
end



# Migration entrypoint
def migrate_user_contacts!
  puts "[USER CONTACT MIGRATION]"
  puts " | Hey, new dev!  Are you certain you need to be running this migration again?  ~ Terra"
  return

  # 1) Make a hash of all email and phone cols on users that are not within their UserSocials
  puts "1) Discover missing UserSocial contacts..."
  missing_contacts = missing_usersocial_contacts


  # 2) Clean contacts as necessary
  puts "2) Clean missing contacts..."
  missing_contacts.each do |contact|
    printf '.'
    contact.clean!
  end


  # 3) Make a list of all duplicate emails,phones within the missing contacts and UserSocials
  puts "3) Discover all duplicate email,phone contacts..."
  duplicates = {email:[], phone:[]}
  missing_contacts.each do |contact|
    duplicates[contact.network] << contact.identifier
  end
  [:email, :phone].each do |network|
    duplicates[network].push(*UserSocial.unscoped.where(type_of: network).pluck(:identifier).duplicates)
    duplicates[network].uniq!
  end


  # 4) call UserSocial.default_primaries() on all users for both networks
  puts "4) Set default primary socials on all users..."
  User.all.each do |user|
    [:email, :phone].each do |network|
      printf '.'
      UserSocial.set_default_primary(user.id, network)
    end
  end
  printf "\n"


  # 5) Iterate over the missing contacts make UserSocial objects for each
  #    5a) If it was "deactivated" and required cleaning, set it as inactive.
  #    5b) If it is a duplicate, make a UserSocial with randomized identifier,
  #        set it inactive, save it, then call update_column to bypass uniquness constraints.
  puts "5) Create missing UserSocials (cleaning emails when necessary)..."

  # Random emails and phones need to satisfy Jon's needlessly-complicated VALID_(PHONE|EMAIL)_REGEXs
  random_letters = lambda{ |len| (('a'..'z').to_a*len).sample(len).join }
  random_numbers = lambda{ |len| (    (2..8).to_a*len).sample(len).join }
  random_email   = lambda{ "contact-migration+#{random_letters.call(16)}@generated.email" }
  random_phone   = lambda{ "1" + random_numbers.call(3) + "555" + random_numbers.call(4) }  # 1 (xxx) 555-xxxx

  missing_contacts.each do |contact|
    printf '.'
    social = UserSocial.new
    social.user_id    =  contact.user_id
    social.type_of    =  contact.network
    social.identifier =  contact.identifier
    social.active     = !contact.cleaned?

    # Is it a duplicate?
    if duplicates[contact.network].include?(contact.identifier) || UserSocial.unscoped.where("identifier ILIKE '#{contact.identifier}'").count > 0
      # Set it as inactive
      social.active = false

      # Use a randomized string for the identifier to ensure uniqueness
      social.identifier = random_email.call()  if contact.network == :email
      social.identifier = random_phone.call()  if contact.network == :phone

      # Save, then update the identifier column with the duplicate contact to bypass uniqueness constraint
      social.save
      social.update_column(:identifier, contact.identifier)
    else
      # Save the non-duplicate social
      social.save
    end
  end # missing contacts
  printf "\n"


  # 6) If the user only has one (active) email or phone social, set it as primary.
  puts "6) Set sole email,phone UserSocials as primary..."  ##x (and update user#phone, user#email accordingly)..."
  missing_contacts.map(&:user_id).uniq.sort.each do |user_id|
    [:phone, :email].each do |network|
      printf '.'
      socials = UserSocial.where(user_id: user_id, type_of: network)
      socials.first.set_primary  if socials.count == 1


      # # 7) Set `user.email` and `user.phone` to the user's primary social, if present
      # _primary = UserSocial.primary.where(user_id: user_id, type_of: network).reload.first.identifier
      # User.find(user_id).update_column(network, _primary)
    end
  end

  puts "\n"
end



def post_migrate_check
  puts "7) Post-migration test..."
  missing_primaries = {}

  networks = [:email, :phone]
  socials = UserSocial.unscoped.where(type_of: networks).preload(:user)
  User.all.each do |user|
    printf '.'
    user_socials = socials.where(user: user)

    missing = networks - user_socials.primary.pluck(:type_of).map(&:to_sym)
    next if missing.empty?

    networks.each do |network|
      missing -= [network]  unless user.send(network).present?
      missing -= [network]  if user_socials.where(active: true, type_of: network).count.zero?
    end
    missing_primaries[user.id] = missing  unless missing.empty?
  end
  printf "\n"

  missing_primaries
end



def promote_primary_socials
  puts "8) Save all primary UserSocials to user#phone, user#email..."
  UserSocial.primary.each do |primary|
    printf '.'
    next unless primary.type_of.present?
    next unless %w[email phone].include? primary.type_of.to_s
    User.find(primary.user_id).update_column(primary.type_of, primary.identifier)
  end
  printf "\n"
  puts "Done.\n\n"
end

# start=DateTime.now ; migrate_user_contacts! ; finish=DateTime.now ; pp start ; pp finish ; nil

# start=DateTime.now ; missing_primaries = post_migrate_check ; finish=DateTime.now ; pp missing_primaries ; pp start ; pp finish ; nil