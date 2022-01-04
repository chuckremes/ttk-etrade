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

The long term plan is to provide access to multiple
brokers without requiring any changes to the
strategies. I am abstracting away the broker differences.
Ruby's duck typing plays a major role in this effort.

The `ttk-containers` gem defines the standard interfaces
for all major objects. Using modules and a set of
shared specs, broker implementations can include
those modules and execute those shared specs to confirm
that the broker code adheres to the correct interfaces.

For ETrade, most of the concrete implementations occur
in the market, portfolio, account, and order 
namespaces. Under each namespace is a `containers`
directory that defines a `Response` class which wraps
the raw JSON response from the broker API. These
classes are a thin façade or presentation pattern
around the broker data to transform it into the data
format expected by the higher level TTK code.

These response classes `include` the modules from
`ttk-containers` and their specs delegate a lot of the
testing to the shared specs from that gem too. This
ensures that the ETrade responses conform to the
correct container API and behavior.

Also, in many cases we define a wrapper container at
`ttk/etrade/containers` which wrap the `Response` objects
and *delegate* all calls to them. This wrapper 
provides a simple mechanism for updating the 
containers with new responses as new data flows in
from the API. Other
code may hold a reference to the wrapper container.
When an update arrives, we can swap in a new Response
object (see `__setobj__`) to update the contents
without disturbing the wrapper reference object!

This is particularly useful for quotes which update
regularly. We avoid the complexity of a pub/sub
architecture for the simplicity of direct object 
updates. It also neatly handles a one-to-many update
structure. There may be multiple distinct wrapper
objects all wrapping the exact same Response object
(though this isn't a pattern to encourage). Smart Boys
will note that this is probably not thread-safe and no
work has been done to make it so; that's out of
scope for now.