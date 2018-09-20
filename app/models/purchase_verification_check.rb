class PurchaseVerificationCheck < ActiveRecord::Base
  # Usage: PurchaseVerification.for(purchase_params:).verify_check(response)

  HEX_ID_PREFIX = 'vc_'
  include HexIdMethods

  after_create :update_parent_check_count
  before_save :update_expiry
  after_save :update_parent_expiry

  # Us #verification instead of #purchase_verification to reference the parent
  belongs_to :verification, class_name: 'PurchaseVerification', foreign_key: 'verification_id'

  # ------------

  FAIL_SEVERITY = Hash.new(0).merge(sms: 20, ideology: 50)  # Default to 0
  PASS_SEVERITY = Hash.new(0).merge(sms: 10, ideology: 20)
  LOCKOUT_THRESHOLD = 100

  # ------------

  # Convert all DateTime's to UTC because otherwise Postgres will compare them incorrectly (see PurchaseVerification scopes for details)
  scope :pending,  -> { where("expires_at >  '#{DateTime.now.utc}'").where(verified_at: nil, failed_at: nil) }
  scope :expired,  -> { where("expires_at <= '#{DateTime.now.utc}'").where(verified_at: nil, failed_at: nil) }
  scope :verified, -> { where.not(verified_at: nil) }
  scope :failed,   -> { where.not(  failed_at: nil) }

  def where_session(session_id) ; where(session_id: session_id) ; end
  def where_rule(rule_name)     ; where(rule_name: rule_name)   ; end

  def expired?  ; (self.expires_at.present? && (self.expires_at <= DateTime.now.utc) && !(self.verified? || self.failed?)) ; end
  def verified? ; (self.verified_at.present?) ; end
  def failed?   ; (self.failed_at.present?)   ; end

  def status
    return :expired   if expired?
    return :verified  if verified?
    return :failed    if failed?
    return :pending
  end

  def deferred? ; (self.check_type.to_s.downcase.include? "await") ; end

  def orphaned?
    return false  if self.verification.present?
    return nil    if self.id.nil?  # Not saved yet.
    puts "\n[model PurchaseVerificationCheck(#{self.hex_id || self.id}) :: orphaned?]  Orphaned PVC detected!"
    true
  end



  # ------------


  def self.for(session_id:, type:, rule:)
    puts "\n\n[model PurchaseVerificationCheck :: for]"
    verification = PurchaseVerification.find_by_session_id(session_id)
    puts "\n[concern PurchaseVerificationCheck :: for]"
    puts " | verification: #{verification.hex_id}"
    puts " | rule:         #{rule}"
    puts " | type:         #{type}"
    # Don't create a duplicate PVCheck if it already exists  (e.g. due to multiple verify() calls)
    check = self.pending.where(rule_name: rule, session_id: session_id, check_type: type)  ##x .first
    puts "\n[model PurchaseVerificationCheck :: for]"
    puts " | sql: #{check.to_sql}"
    check = check.first  if check.present?   # temporary while the debugging is in place

    unless check.present?
      puts "\n[model PurchaseVerificationCheck :: for]  Building new PVCheck"
      pvc = {
          session_id:      verification.session_id,
          verification_id: verification.id,
          rule_name:       rule,
          check_type:      type,  # `type` is a magic Rails keyword
      }
      check = new(pvc)
    end

    check
  end


  # ------------


  def verify(response)
    # This function stores `result` and saves it (and the user's response) on the PVCheck object within `ensure`
    # While a little messy, this prevents both unnecessary indentation within this function,
    # as well as adding another function whose only purpose is to catch and save that result.

    puts "\n\n[model PurchaseVerificationCheck(#{self.hex_id}) :: verify]"
    puts " | response: #{response}"

    # Check for failure
    if self.verification.failed?
      puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: verify]  parent verification failed!  Not verifying."
      return result = parent_failed
    end

    # Check for expiry
    if expired?
      puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: verify]  expired! Not verifying."
      return result = expire
    end
    # Check for e.g. sms_await  (incorrect api call order)
    if deferred?
      puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: verify]  deferred! Not verifying."
      return result = defer
    end

    # Call the appropriate verify method and get its verdict
    result = syndicate_verify(response)

    if result[:verdict] == :pass
      puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: verify]  pass!"
      return result
    end

    # Oh no, a failure!  Tally up each check's severity
    total_severity = 0
    # noinspection RubyResolve
    self.verification.checks.each do |check|
      total_severity += FAIL_SEVERITY[check.check_type.to_sym]  if check.failed?
      total_severity -= PASS_SEVERITY[check.check_type.to_sym]  if check.verified?
    end

    puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: verify]  lockout!"  if total_severity >= LOCKOUT_THRESHOLD

    # If the user fucked up badly enough, lock them out; otherwise, issue a normal failure response.
    result = ((total_severity >= LOCKOUT_THRESHOLD) ? lockout! : fail!)

  ensure
    # Store the response and result on the PVCheck object
    timestamp = DateTime.now.utc
    self.response = {timestamp: timestamp, response: response}
    self.result = result.merge({timestamp: timestamp}).as_json
    self.save
  end



  # ------------
  # Update hooks


  def update_parent_check_count
    return if orphaned?

    self.verification.check_count += 1
    self.verification.save
  end

  def update_expiry
    return if self.expires_at.present?
    self.expires_at = 5.minutes.from_now  ##+ Determine lockout duration from ruleset after speaking with Craig
  end

  def update_parent_expiry
    return if orphaned?

    ##?  This will call the PurchaseVerification before_save filter, which basically does the same thing.
    ##?  But would calling `self.verification.save` without any changes actually trigger it?
    self.verification.expires_at = self.expires_at
    self.verification.save
  end



  # ------------
  # Verifications


  def syndicate_verify(response)
    # Call the specific verify method for this PVCheck type
    puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: syndicate_verify]"
    method_name = "_verify_#{self.check_type}"
    return self.send(method_name, response)  if self.respond_to?(method_name)

    # But if there isn't one...?
    puts " | It's someone's lucky day!  I don't know how to verify this type of check."
    puts " | type: #{self.check_type}"
    puts " | id:   #{self.hex_id} (#{self.id})"
    self.verified_at = DateTime.now.utc

    pass!
  end


  def _verify_sms(response)
    puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: _verify_sms]"
    puts " | Comparing '#{response.downcase.strip}' to '#{self.data['code']}'"
    #TODO: If the code is from an unverified UserSocial phone number, verify it

    return pass!  if response.downcase.strip == self.data['code']

    # Verification failure.
    puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: _verify_sms]  Failed SMS check. Duplicating to allow easy re-verifying"
    # Duplicate this check (for lockout tallying) and reset the cols we don't want to keep.
    # The next call to /web/v3/gifts/verify (PV#verify_check) will fetch this new record,
    # allowing the user to verify against the same code again. This also means we don't send any unnecessary texts!

    # The reason this is here and not in PVC#verify is that we will likely want
    # to disallow retries on more stringent checks such as Ideology.
    self.dup.update(hex_id: nil, failed_at: nil, response: nil, result: nil)  # Also saves the record
    fail!
  end



  # ------------
  # Verdicts


  def pass!
    puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: pass!]"
    self.update(verified_at: DateTime.now.utc)
    {verdict: :pass, success: true}
  end


  def fail!
    puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: fail!]"
    # Both verify() and syndicated verifies call this.  Only update once.
    self.update(failed_at: DateTime.now.utc)  unless self.failed_at.present?
    {verdict: :fail, success: false}
  end

  def parent_failed
    # The PurchaseVerification is marked as failed, yet someone is trying to re-verify the last check?
    {verdict: :parent_failed, success: false}
  end

  def expire
    # No need to do anything here.
    # Expired PV/PVChecks simply aren't interacted with.
    # Also, expired verifications should not count against the user in any way.
    {verdict: :expired, success: false}
  end

  def defer
    {verdict: :defer, success: false}
  end

  def lockout!
    puts "\n[model PurchaseVerificationCheck(#{self.hex_id}) :: lockout!]"
    lockout_duration = 30.minutes
    now = DateTime.now.utc

    self.update(failed_at: now)
    self.verification.update(failed_at: now)
    self.verification.user.purchase_lockout_for lockout_duration

    {verdict: :lockout, success: false, duration: lockout_duration}
  end

end



__END__

pvc = PurchaseVerificationCheck.new(session_id: 'pcd')
pvc = PurchaseVerificationCheck.last