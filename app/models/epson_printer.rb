class EpsonPrinter < ActiveRecord::Base
    belongs_to :client

    def offline?
        (self.last_poll_capture_at.present? && self.last_poll_capture_at <= 12.hours.ago)
    end

    def paper_low?
        self.paper_low_at.present?
    end

    def paper_out?
        # Within 12 minutes they may be changing the paper.
        (self.paper_out_at.present? && self.paper_out_at <= 12.minutes.ago)
    end

    def has_mechanical_error?
        self.last_mechanical_error_at.present?
    end

    def has_cutter_error?
        self.last_cutter_error_at.present?
    end

    def has_recent_mechanical_error?
        has_mechanical_error? && self.last_mechanical_error_at > 1.week.ago
    end

    def has_recent_cutter_error?
        has_cutter_error? && self.last_cutter_error_at > 1.week.ago
    end

    def cover_open?
        self.cover_open_at.present?
    end

    def cover_left_open?
        cover_open? && self.cover_open_at <= 30.minutes.ago
    end

end
