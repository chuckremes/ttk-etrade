require "oj"

# Vendor-specific configuration classes that know how to transform a
# relatively flat key/value json file into a richer structure to
# be consumed by this toolkit.
#
# These classes are intended to set sane defaults when keys are missing
# and to do validation on entered keys. Errors should be raised for
# invalid values or unknown keys.
#
class TTK::ETrade::Config
  def initialize(contents)
    setup_structure
    fill_structure(contents)
  end

  def to_json
    Oj.dump(flatten(contents))
  end

  def vendor
    "etrade"
  end

  private

  attr_reader :contents

  def setup_structure
    {
      vendor: vendor
    }
  end

  def flatten(*args)
    {
      vendor: vendor
    }
  end
end
