class SubtleDataController < ApplicationController

    def index
        sd_root = "https://www.subtledata.com/API/M/1/?Q="
        pipe = "%7C"
        web_key = "RlgrM1Uw"
        call = params[:call] || "0000"
        @response = String.new(%x{curl #{sd_root}#{call}#{pipe}#{web_key}})
        respond_to do |format|
            format.js
        end
    end
end
