class ZipCodeValidator < ActiveModel::EachValidator
  ZIP_CODE_REGEX = /\A\d{5}(-\d{4})?\z/

  def validate_each(record, attribute, value)
    unless ZIP_CODE_REGEX.match value
      record.errors.add(attribute, "#{value} is not a valid zip code")
    end
  end
end