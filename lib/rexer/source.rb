module Rexer
  module Source
    def self.from_definition(source)
      const_get(source.type.capitalize).new(**source.options)
    end
  end
end
