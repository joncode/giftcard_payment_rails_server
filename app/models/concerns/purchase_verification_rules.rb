module PurchaseVerificationRules
  # This module runs checks against the purchase and user
  # PurchaseVerificationCheck verifies client responses to these checks.


  # @return [{verdict:, success:, check:}]
  #  | `success` indicates if the api should use success() or fail_web()
  #  | This keeps everything to do with verification self-contained
  def perform
    puts "\n[module PurchaseVerificationRules :: perform]"
    puts " | verification: #{self.hex_id}"

    if self.expired?
      puts " | Expired :<"
      return {verdict: :expired, success: false}
    end


    #TODO: Lookup rules by Merchant
    rules = [:lockout, :failed, :large_gift]

    # Check each rule in series, exiting upon the first failure
    _common_rule_setup(self)  # Passing `self` to bypass linter warnings
    rules.each do |rule|
      # Skip if the user has already passed this check
      next if already_checked?(rule)

      # Call the rule
      check = self.send("rule_#{rule}", self)  # Passing `self` to bypass linter warnings

      # Skip if the user has already passed this type of check (e.g. SMS)
      next if already_passed?(check)

      # Perform the indicated check (if present), and return its verdict
      # This is dynamic so I can pass the rule name along without re-specifying every time
      return self.send(check, self, rule: rule)  if check.present?  # Passing `self` to bypass linter warnings
    end

    # Everything's peachy! (except the linter)  The user may purchase the gift.
    # noinspection RubyResolve
    self.verified_at = DateTime.now
    self.save

    {verdict: :pass, success: true}
  end



  # ------------
  # Rules return:
  #   on pass:  nil
  #   on check: verdict method symbol (:sms_check, etc.)

  def rule_lockout(verification)
    puts "\n[module PurchaseVerificationRules :: rule_lockout]"
    puts " | verification: #{verification.hex_id}"
    ((verification.user.purchase_lockout?) ? :lockout : nil)
  end


  def rule_failed(verification)
    puts "\n[module PurchaseVerificationRules :: rule_failed]"
    puts " | verification: #{verification.hex_id}"
    ((verification.failed?) ? :failed : nil)
  end


  def rule_first_large_gift(verification)
    puts "\n[module PurchaseVerificationRules :: rule_first_large_gift]"
    puts " | verification: #{verification.hex_id}"
    return  unless verification.user.sent.empty?
    return  unless @_value >= 125

    puts " | Triggering SMS check\n\n"
    :sms_check
  end


  def rule_large_gift(_)
    puts "\n[module PurchaseVerificationRules :: rule_large_gift]"
    puts " | Comparing: #{@_value} >= 200"
    return  unless @_value >= 200

    puts " | Triggering SMS check\n\n"
    :sms_check
  end


  # ------------



private


  def _common_rule_setup(verification)
    # Pre-fetch/pre-populate commonly used rule values/lookups
    @_value = verification.value.to_f  # Not in cents.
  end


  # ---------------
  # Checks/Verdicts:


  def lockout(*_)
    puts "\n[module PurchaseVerificationRules :: lockout]"
    # This simply tells the client they're locked out.
    # The actual lockout happens within PurchaseVerificationCheck::lockout!
    {verdict: :lockout, success: false}
  end


  def failed(*_)
    puts "\n[module PurchaseVerificationRules :: failed]"
    # The user failed too many checks.
    {verdict: :failed, success: false}
  end


  def sms_check(verification, rule:)
    puts "\n[module PurchaseVerificationRules :: sms_check]"
    puts " | verification: #{verification.hex_id}"
    puts " | rule:         #{rule}"

    check = nil
    data  = {}
    msg   = nil

    user_phone = get_user_phone(verification.user)
    type = (user_phone.present? ? :sms : :sms_await)
    check = PurchaseVerificationCheck.for(session_id: verification.session_id, rule: rule, type: type)

    if type == :sms
      data[:phone_number] = user_phone
      data[:code] = (((0..9).to_a.shuffle)*4).join[0...5]  # 5 random digits
      sms_message = "ItsOnMe verification code: #{data[:code]}\nPlease enter this code into the verification field."

      check.request = {timestamp: DateTime.now.utc, sms: sms_message}.as_json
      check.data = data
      check.save

      puts "\n ------------ "
      puts "Sending TWILIO text"
      puts " | to:  #{user_phone}"
      puts " | msg: #{sms_message.gsub(/\n/,"\n        ")}"
      puts " ------------ \n"
      OpsTwilio.text to: user_phone, msg: sms_message   ##!  Can fail; returns {status: 1|0}
    else  # :sms_await
      check.expires_at ||= 1.hour.from_now
      check.save

      msg = "Missing phone number"
    end

    {verdict: :check, success: true, type: type, phone_number: data[:phone_number], msg: msg}.compact
  end


  # ------------


  def already_checked?(rule)
    puts "\n[concern PurchaseVerificationRules :: already_checked?(#{rule})]"
    pvc = PurchaseVerificationCheck
              .verified  \
              .where(rule_name: rule, session_id: self.session_id)  \
              .order(created_at: :desc)  \
              .first


    # No PVCheck for this rule and session
    return false if pvc.nil?
    # "Verified" deferred checks (e.g. sms_await) mean we now have the required data to perform the check
    return false if pvc.check_type.to_s.downcase.include? "await"

    puts "\n[concern PurchaseVerificationRules :: already_checked?(#{rule})]  Already checked."
    true
  end


  def already_passed?(check_type)
    puts "\n[concern PurchaseVerificationRules :: already_passed?(#{check_type})]"

    # Only allow bypassing certain types of checks
    return false  unless %i[sms_check].include? check_type

    # Pull the last PVC with the same check_type
    pvc = PurchaseVerificationCheck
              .verified  \
              .where(check_type: check_type, session_id: self.session_id)  \
              .order(created_at: :desc)  \
              .first

    return false  if pvc.nil?
    true
  end


  def get_user_phone(user)
    social = UserSocial.best(user.id, :phone)
    (social.present? ? social.identifier : user.phone)
  end

end



__END__

sms check? flag user to sms_verify next purchase

document flow and edge cases


no phone number
type: sms_code
client collects number, optionally update user object with data
client calls verify_resume(sms|email, social_id) to trigger the Twilio code
client calls verify_response()


code_verify (sms->email fallback)


purchase -> verify() -> fail, not verify response.

talk to david/craig about minor verification failures, e.g. first gift that's $100 and the user has no phone.
