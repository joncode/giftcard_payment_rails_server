class MoveRegiftDataToPayableOnGifts < ActiveRecord::Migration
  def up
    # find all gifts that have been regifted
    # find all their children
    # make the old gift the payable of the child
    # set the old gift status - "complete_regifted"
    # set any integer status
    # set the old gift pay_stat - "charge_regifted"
    # set any integer pay_stat
    # confirm the pay stat of new gift is atleast pay stat of old gift
  end

  def down

  end
end
