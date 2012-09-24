koders
======

## Getting Started

- Copy config_sample.yml to config.yml
- Run create_github_token.rb, copy token and add that to config.yml
- Fill in the rest of config.yml

## Running Workers (ie: collecting and processing the big data)

- rake workers:upload
- rake run

## Running the UI

- Run config_pusher.rb: `ruby config_pusher.rb`
- Create a heroku app: `heroku apps:create myapp`
- Push code: `git push heroku master`
