class PurchaseVerification < ActiveRecord::Base
  # Usage:
  #  | PurchaseVerification.for(purchase_params).perform
  #  | PurchaseVerification.for(purchase_params).verify_check(response)

  HEX_ID_PREFIX = 'pv_'
  include HexIdMethods
  include PurchaseVerificationRules

  before_save :update_expiry

  belongs_to :user
  belongs_to :merchant
  belongs_to :gift
  # Shorten method (to #checks) and foreign key (from `purchase_verification_id`)
  has_many :checks, class_name: 'PurchaseVerificationCheck', foreign_key: 'verification_id'

  # ------------

  # Convert all DateTime's to UTC because otherwise Postgres will compare them incorrectly,
  # resulting in scenarios where e.g. a record is both pending and expired.
  # Reason: The column in the database is a `datetime` (therefore lacking timezone info),
  #         and apparently Postgres doesn't compare these correctly with ISO8601 literals
  #         with TZ data from Rails (`DateTime.now.to_s` or "2018-07-23T19:39:10-07:00").
  scope :pending,  -> { where("expires_at >  '#{DateTime.now.utc}'").where(verified_at: nil, failed_at: nil) }
  scope :expired,  -> { where("expires_at <= '#{DateTime.now.utc}'").where(verified_at: nil, failed_at: nil) }
  scope :verified, -> { where.not(verified_at: nil) }
  scope :failed,   -> { where.not(  failed_at: nil) }

  # Expired records have passed their expiry without having been verified or failed.
  def expired?  ; (self.expires_at.present? && (self.expires_at <= DateTime.now.utc) && !(self.verified? || self.failed?)) ; end
  def verified? ; (self.verified_at.present?) ; end
  def failed?   ; (self.failed_at.present?)   ; end

  # ------------

  def self.for(purchase_params)
    puts "\n[model PurchaseVerification :: for]"
    params = purchase_params.symbolize_keys

    # Find the existing verification for this session
    verification = self.for_session(params[:session_id])

    # or create a new one if it isn't already present
    unless verification.present?
      verification = self.new
      verification.session_id  = params[:session_id]
      verification.user_id     = params[:giver].id
      verification.merchant_id = params[:merchant_id]
      verification.value       = params[:value]
      verification.cart        = params[:shoppingCart]
      verification.save
    end

    verification
  end

  # @return PurchaseVerification
  def self.for_session(session_id)
    # Note: Duplicate session_id's will simply return an expired PV.
    where(session_id: session_id).first
  end


  # ------------
  # perform() and all rules are located within the PurchaseVerificationRules concern
  # ------------


  # The PurchaseVerificationCheck model handles the actual checking, as its name implies
  def verify_check(response)
    puts "\n[model PurchaseVerification(#{self.hex_id}) :: verify_check]"
    puts " | response: #{response}"
    self.checks.last.verify(response)
  end



  def deferred_sms
    puts "\n[model PurchaseVerification(#{self.hex_id}) :: deferred_sms]"
    # Look up the deferred sms check
    await = self.checks.pending.where(check_type: :sms_await).first

    # if there isn't one, bail.
    return if await.nil?

    ##FIXME `sms_await -> verify_resume()` with no phone number will verify and create a new sms_await check each time.  Doesn't actually cause issues, but can create db clutter.

    # verify it
    await.verified_at = DateTime.now.utc
    await.save

    # Then re-run the rules again.
    # This will (unless the rules changed between api calls) trigger the same check again.
    # If the user still doesn't have a phone number, it will generate another :sms_await
    perform
  end


private


  def update_expiry
    puts "\n[model PurchaseVerification(#{self.hex_id}) :: update_expiry]"
    # Set `expires_at` to that of the most recent check, or default when missing
    checks = self.checks.pending.order(expires_at: :desc)

    if checks.count == 0
      self.expires_at ||= 5.minutes.from_now
      puts " | expiry:  5.minutes  (default)"
      return
    end

    self.expires_at = checks.first.expires_at
    puts " | expiry:  #{self.expires_at}  (from #{checks.first.hex_id})"
  end


end


__END__

pv = PurchaseVerification.new(session_id: 'pcd', user_id: 1106, merchant_id: 822, value: "35000"); pv.save
pv = PurchaseVerification.last



I've made significant progress on anti-fraud;
it's gotten pretty involved, but I think i've addressed everything we'll need in the future.
I'm finishing up deferred sms verification, which should be ready for brandon's testing tonight.

Also, we should discuss the spearmint rhino email.
I don't believe we have an API for merchantTools gifts yet, so I'll need to build that.

