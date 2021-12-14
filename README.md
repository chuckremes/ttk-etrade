# What

ETrade support for the Trading Tool Kit.

# How

Most of these classes implement an interface that the TTK supports via duck typing. If the interface is followed, then this stuff Just Works.

# Structure

    accounts ->
              |
              - account --               -  EquityPosition
                         |- balances     |- OptionPosition
                         |- positions ---|- SpreadPosition
                         |- orders       -  FuturesPosition

# Rate Limits

ETrade REST API v1 (circa 2018) has the following rate limits per their support team.

* Accounts Module = 35,600 / hour or 9.8 / second
* Markets Module = 140,000 / hour or 38.8 / second
* Orders Module = 17,800 / hour or 4.9 / second
* Users Module = 35,600 / hour or 9.8 / second

They note that Options Chains use the Markets module so downloading lots of chains repeatedly can rapidly consume the quota. Each OptionPair associated with a strike in an option chain is considered as 2 quote requests. So downloading a chain with 50 strikes for CallPut will consume 100 quote requests for that hour. Downloading many chains repeatedly can rapidly consume the whole 140k hourly limit.

# Plans

1. Make it work
2. Make it right
3. Make it fast

Still in phase #1 where I'm making it work. When I get to "make it right" then there will be additional refactors and lots of unit and integration tests. This code needs to be trustworhty. While it currently works, it needs tests to make sure it continues to work.


# Notes

