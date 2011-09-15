# Rails Instrument

This gem is a middleware which add some instrumentation details like db
runtime, view runtime, numner of sqls fired for each request in the
response headers.

## Response headers added

* X-View-Runtime
* X-DB-Runtime
* X-DB-Query-Count


## Installation

Install the latest stable release:

  [sudo] gem install rails_instrument

In Rails >= 3, add it to your Gemfile:

``` ruby
gem 'carrierwave'
```


## TODO
* Create chrome extension to show this information inline in the page
* Add helper methods for tests. Ex: The number of sqls fired can be
  asserted. - wip
* Add tests coverage.
