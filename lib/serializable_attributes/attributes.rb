module SerializableAttributes

  # Stores the (decoded) serialized attributes.
  # A hash with a default proc is not marshallable, so this fixes the issue.
  # The data doesn't need to be marshalled because it can be retrieved from the raw data.
  class Attributes < ::Hash
    def marshal_dump
      ::Hash[to_a]
    end

    def marshal_load(data)
      merge!(data)
    end
  end
end