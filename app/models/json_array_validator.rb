class JsonArrayValidator < ActiveModel::Validator

    def validate(record)
        if record.menu
            begin
                menu = JSON.parse(record.menu)
                unless menu.kind_of?(Array)
                    record.errors["menu"] << "JSON not an array after parse"
                end
            rescue
                record.errors["menu"] << "Not JSON formatted"
            end
        else
            record.errors["menu"] << "cannot be nil"
        end
    end


end
