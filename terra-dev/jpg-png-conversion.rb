# Note: This png->jpg conversion is to reduce Cloudinary bandwidth, but causes unknown issues.
#       Resolving them was always supplanted with other priorities, so finding and fixing them
#       is now up to you.  Good luck!

def conversion(simulation: true)
    log "[Converting png->jpg]"
    start = DateTime.now

    clear_urls

    {
        AtUser:      [:photo, :min_photo],
        Book:        [:photo1, :photo2, :photo3, :photo4, :photo_banner, :photo_logo, :photo5],
        Brand:       [:logo, :photo],
        Campaign:    [:photo, :photo_path],
        LandingPage: [:banner_photo_url, :sponsor_photo_url],
        # List:        [:photo, :logo],
        MenuItem:    [:photo],
        # Merchant:    [:photo, :photo_l, :image],
        MtUser:      [:photo, :min_photo],
        Oauth:       [:photo],
        Place:       [:photo],
        Proto:       [:photo, :item_photo],
        Region:      [:photo],
        SupplyItem:  [:photo_url],
        User:        [:iphone_photo],
    }.each do |const, cols|
        png_to_jpg(const, cols, simulation: simulation)
    end

    finish = DateTime.now
    log "Finished."
    log ""
    log "Time:"
    log "Start:    #{start}", indent: 1
    log "Finish:   #{finish}", indent: 1
end

def png_to_jpg(const, cols, simulation:true)
    const = const.to_s.constantize

    cols.each do |col|
        const.where.not(col => nil).each do |row|
            next unless row[col].downcase.include? "cloudinary"
            next unless row[col].downcase.ends_with? ".png"
            add_url row[col]

            log "#{const}.#{col}:\t#{row[col]}"  if simulation

            next if simulation
            row[col].gsub!(/\.png$/i,'.jpg')
            row.save
        end
    end
end


def log(str, indent:0)
    str = (" | " * indent) + str
    @log ||= []
    @log << str
    puts str
end

def fetch_log
    @log
end

def clear_urls
    @urls = []
end

def add_url(url)
    @urls << url
end

def urls
    @urls
end


conversion simulation: true