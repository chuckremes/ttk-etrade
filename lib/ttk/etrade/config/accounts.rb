class TTK::ETrade::Config::Accounts < TTK::ETrade::Config

  def allowed_accounts
    contents[:allowed_accounts]
  end

  def active_only
    contents[:active_only]
  end

  def primary_account_id
    contents[:primary_account_id]
  end

  def types
    contents[:types]
  end

  def institution_types
    contents[:institution_types]
  end

  private

  def setup_structure
    @contents = {
      allowed_accounts:    nil,
      primary_account_id: nil,
      active_only:        nil,
      types:              nil,
      institution_types:  nil,
    }.merge(super)
  end

  def fill_structure(hash)
    contents[:allowed_accounts]   = hash.dig("accounts", "allowed_accounts") || []
    contents[:primary_account_id] = hash.dig("accounts", "primary_account_id")
    contents[:active_only]        = hash.dig("accounts", "active_only") || true
    contents[:types]              = hash.dig("accounts", "types") || []
    contents[:institution_types]  = hash.dig("accounts", "institution_types") || []
  end

  def flatten(contents)
    {
      accounts: {
                  allowed_accounts:   contents[:allowed_accounts],
                  primary_account_id: contents[:primary_account_id],
                  active_only:        contents[:active_only],
                  types:              contents[:types],
                  institution_types:  contents[:institution_types],
                }.merge(super)
    }
  end
end
