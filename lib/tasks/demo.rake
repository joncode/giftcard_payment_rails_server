namespace :gifts do

    desc "demo gifts"
    task demo: :environment do
        require 'demo_gifts'
        DemoGifts::perform
    end

end