# kanojo bot. [![Code Climate](https://codeclimate.com/github/sugamasao/kanojo_bot.png)](https://codeclimate.com/github/sugamasao/kanojo_bot) [![Build Status](https://travis-ci.org/sugamasao/kanojo_bot.png?branch=master)](https://travis-ci.org/sugamasao/kanojo_bot)

[@sugyan_knj_bot](https://twitter.com/sugyan_knj_bot) loves @sugyan

inspired by [genki-bot](https://github.com/sugyan/genki-bot)
----

## how to use

get access token.

```sh
export TWITTER_CONSUMER_KEY=your key
export TWITTER_CONSUMER_SECRET=your secret
export TWITTER_ACCESS_TOKEN=your token
export TWITTER_ACCESS_TOKEN_SECRET=your token secret
```

execute KanojoBot.daisuki

```sh
% bundle install
% bundle exec ruby bin/kanojo_bot
```

## how to add word?

editting for yaml.

- [add match word and response variation](data/samishisou.yaml) （すぎゃーんの言葉に反応するリアクション）
- [add end word variation](data/hagemashitai.yaml) （レスポンスの最後にランダムで追加する文字列）
- [add face variation](data/face.yaml) （使用する顔文字）

## Heroku to Deploy
```sh
heroku config:set BUNDLE_WITHOUT="development:test"
```
