koders
======

## Getting Started

- Run `bundle install`
- Copy config_sample.yml to config.yml
- Run create_github_token.rb, copy token and add that to config.yml
- Fill in the rest of config.yml

## Running Workers (ie: collecting and processing the big data)

- `rake workers:upload`
- `rake run`

To cleanup the data after a run:

- `rake cleanup`

## Running the UI

Locally:

- `rackup`

On Heroku:

- Run config_pusher.rb: `rake config:push`
- Create a heroku app: `heroku apps:create myapp`
- Push code: `git push heroku master`

