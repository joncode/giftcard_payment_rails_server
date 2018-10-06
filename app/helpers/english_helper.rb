module EnglishHelper

    # a("apple") => "an apple"
    # Caveat: does not handle phonetic irregularities: a("unicorn") returns "an unicorn"
    def a(string)
        (%w[a e i o u].include?(string.to_s[0].downcase) ? 'an ' : 'a ') + string.to_s
    end
    alias_method :an, :a

end
