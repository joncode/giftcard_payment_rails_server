class GolfnowMerchantSubmittedSysAlert < Alert

    def text_msg
        get_data(type: :text)
        "#{name_string}\n#{@data}"
    end

    def email_msg
        get_data(type: :email)
        "<div><h2>#{name_string}</h2><p>#{@data}</p></div>".html_safe
    end

    def msg
        text_msg
    end

#   -------------

    def get_data(type: :email)
        signup = @target

        # Handle potential cases where @target is a Hash
        # (Copied and rewritten from MerchantSubmittedSysAlert)
        unless signup.kind_of?(MerchantSignup)
            # Bail if the ID is missing or invalid
            # (because we don't want to send GolfNow a malformed alert)
            return nil  unless signup['id'].present?
            return nil  unless signup['id'].to_i >= 0

            # Bail if there's no signup for the given ID
            signup = MerchantSignup.find(signup['id'].to_i)  rescue nil
            return nil  if signup.nil?
        end


        title = "<strong><u>New GolfNow Signup</u></strong><br/><hr/>"
        body  = construct_body(signup, type: type)


        if type == :email
            return @data = (title+body)
        end

        # Non-email?
        # Strip out all markup, replacing <hr/> and <br/> accordingly
        @data = (title+body).gsub(/<hr\/?>/, ('-'*18) + "\n")
                            .gsub(/<br\/?>/, "\n")
                            .gsub(/<.+?>/,   '')
    end


    def construct_body(signup, type: :email)
        _contact  = signup.name
        _contact += " (#{signup.position})"  if signup.position.present?
        _url      = nil
        _url      = "<a href='#{signup.venue_url}'>#{signup.venue_url}</a>"  if signup.venue_url.present?
        _gn_url   = signup.data['venue']['golfnow_url']    rescue nil
        _gn_url   = "<a href='#{_gn_url}'>#{_gn_url}</a>"  if _gn_url.present?

        _fid       = signup.data['venue']['golfnow_facility_id']  rescue nil
        _rep_name  = signup.data['contact']['golfnow_rep_name']   rescue nil
        _rep_email = signup.data['contact']['golfnow_rep_email']  rescue nil
        _rep_email = "<a href='#{_rep_email}'>#{_rep_email}</a>"  if _rep_email.present?

        # Construct address out of whatever data is available.
        # (n.b.: The below uses `reject(&:empty?)` to remove empty strings produced by e.g. `[].join`)
        _address = ''
        begin
            # Address, first line:
            _address  = [ signup.data['venue']['address'] ]

            # Address, second line:  ("City, State zip")
            _address2 = [ signup.data['venue']['city'], signup.data['venue']['state'] ]
            _address2 = [ _address2.compact.join(', '), signup.data['venue']['zip']   ]
            _address2 = _address2.compact.reject(&:empty?).join(' ')

            # join!
            _address  = [_address, _address2].compact.reject(&:empty?).join(', ')
        rescue
            _address = ''
        end

        # Default to nil so we can display '(not provided)' below
        _address = nil  if _address.empty?



        body = []
        body << ['Course Name',   signup.venue_name]
        body << ['Address',       _address]                  if type == :email  # due to length
        body << ['URL',           _url]
        body << ['GolfNow URL',   _gn_url]
        body << ['Facility ID',   _fid]
        body << nil
        body << ['Contact',  _contact]
        body << ['Email',    signup.email]
        body << ['Phone',    number_to_phone(signup.phone)]  if signup.phone.present?

        if _rep_name.present? || _rep_email.present?
            body << nil
            body << ['GolfNow Rep Name',  _rep_name]
            body << ['GolfNow Rep Email', _rep_email]
        end

        if signup.data.present? && signup.data['contact']['notes'].present?
            body << nil
            body << ['Extra info', signup.data['contact']['notes']]
        end

        if type == :email
            # Only include these in emails because of their length
            # Two line breaks to make these easier to distinguish
            body << nil
            body << ['Short description', signup.data['venue']['zinger']]
            body << nil
            body << ['Long description',  signup.data['venue']['description']]
        end


        # Construct the body's markup given the collected data
        body.collect do |line|
            if line.nil?
                # Linebreak (will be after joining, anyway)
                ''
            else
                # *Term:* info
                "<strong>#{line.first}:</strong> #{line.last || '<i>(not provided)</i>'}"
            end
        end.compact.join('<br/>')
    end

end
