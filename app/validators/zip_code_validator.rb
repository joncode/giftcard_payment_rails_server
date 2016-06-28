class ZipCodeValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEX = /(^\d{5}(-\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\d{1}[A-Z]{1} *\d{1}[A-Z]{1}\d{1}$)/

  def validate_each(record, attribute, value)
    unless ZIP_CODE_REGEX.match value
      record.errors.add(attribute, "#{value} is not a valid zip code")
    end
  end
end