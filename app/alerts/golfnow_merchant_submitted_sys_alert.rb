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
        body  = construct_body(signup)


        if type == :email
            return @data = (title+body)
        end

        # Non-email?
        # Strip out all markup, replacing <hr/> and <br/> accordingly
        @data = (title+body).gsub(/<hr\/?>/, ('-'*18) + "\n")
                            .gsub(/<br\/?>/, "\n")
                            .gsub(/<.+?>/,   '')
    end


    def construct_body(signup)
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

        body = []
        body << ['Course Name',   signup.venue_name]
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


        # Construct the body's markup given the collected data
        body.collect do |line|
            if line.nil?
                # Linebreak (will be after joining, anyway)
                ''
            elsif line.last.nil?
                # Pass if there's no data
                nil
            else
                # *Term:* info
                "<strong>#{line.first}:</strong> #{line.last}"
            end
        end.compact.join('<br/>')
    end

end
