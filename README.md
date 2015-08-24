# kanojo bot.

[![Build Status](https://travis-ci.org/sugamasao/kanojo_bot.png?branch=master)](https://travis-ci.org/sugamasao/kanojo_bot)
[![Code Climate](https://codeclimate.com/github/sugamasao/kanojo_bot.png)](https://codeclimate.com/github/sugamasao/kanojo_bot)
[![Test Coverage](https://codeclimate.com/github/sugamasao/kanojo_bot/badges/coverage.svg)](https://codeclimate.com/github/sugamasao/kanojo_bot)
[![Inline docs](http://inch-ci.org/github/sugamasao/kanojo_bot.svg?branch=master)](http://inch-ci.org/github/sugamasao/kanojo_bot)

[@sugyan_knj_bot](https://twitter.com/sugyan_knj_bot) loves @sugyan

inspired by [genki-bot](https://github.com/sugyan/genki-bot)
----

## how to use(local)

### get self access token

- [dev.twitter.com](https://dev.twitter.com)
  - Accesse Level : Read and write
- [docomo Developersupport](https://dev.smt.docomo.ne.jp/)
  - use `雑談対話` key
### set env

```sh
export TWITTER_CONSUMER_KEY=your key
export TWITTER_CONSUMER_SECRET=your secret
export TWITTER_ACCESS_TOKEN=your token
export TWITTER_ACCESS_TOKEN_SECRET=your token secret
export DOCOMO_API_KEY=your API key
```

or `vi .env` (using dotenv)

```sh
TWITTER_CONSUMER_KEY=your key
TWITTER_CONSUMER_SECRET=your secret
TWITTER_ACCESS_TOKEN=your token
TWITTER_ACCESS_TOKEN_SECRET=your token secret
DOCOMO_API_KEY=your API key
```

### execute KanojoBot.daisuki

```sh
% bundle install
% bundle exec ruby bin/kanojo_bot -d
```

WARNING: not use `-d` is really post(You will want to Bitch).

## how to add word?

editting for yaml.

- [add match word and response variation](data/samishisou.yaml) （すぎゃーんの言葉に反応するリアクション）
- [add end word variation](data/hagemashitai.yaml) （レスポンスの最後にランダムで追加する文字列）
- [add face variation](data/face.yaml) （使用する顔文字）

## Heroku to Deploy
```sh
heroku config:set BUNDLE_WITHOUT="development:test"
```
