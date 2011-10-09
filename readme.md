# Rails Instrument

This gem is a middleware which add some instrumentation details like db
runtime, view runtime, number of sqls fired on each request in the
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
gem 'rails_instrument'
```


## TODO
* <strike>Create chrome extension to show this information inline in the page</strike>. Implemented as html fragment added by the middleware to html response.
* Add helper methods for tests. Ex: The number of sqls fired can be
  asserted. - wip
* Add test coverage.