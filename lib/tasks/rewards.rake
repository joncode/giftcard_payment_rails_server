require 'rewards_generator'

namespace :promo do

    desc "rewards promo"
    task rewards: :environment do
        RewardsGenerator::make_gifts
    end

end