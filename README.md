# moolah

## UPDATE (12/8/2011)

I've stopped working on this project for now, mainly because I realized that having to go to my bank's website, download a CSV, and import it into Moolah every dang month was a pain. What I wanted was to be able to tell Moolah to connect to my bank automatically, but ideally you want to make this possible for multiple banks. Unfortunately in my brief research into this I realized that fetching data from banks is a nightmare -- they just don't make it easy to do this (either because of security reasons or because their software is running on 100 year old computers) and what you end up having to do is write a screenscraper to just pretend to be a user and log in through the web interface. This, incidentally, is exactly what Mint (and before that, Wesabe) does, so it was a lot easier just to switch to that.

With that said, I don't really use Mint anymore because it only does half of what I want. It's nice that it automates a lot of stuff but I'm kind of lazy with it now -- I might check it once a month just to make sure everything's okay. So perhaps the automation isn't a good idea, I don't know. There are also some goals I had with Moolah that Mint doesn't do -- most of them have to do with number crunching to analyze your spending/savings in various ways and give you all sorts of statistics or even a projection of how much you'll have in so many years, or how much you'd have at a certain point in time if you cut your budget in this way. Plus I think Mint still doesn't support custom transactions or splitting transactions in two (although I could be wrong). And the budget feature is kind of annoying, because the way I spend money, I find it to be too inflexible -- how much I spend per month changes depending on what I choose to spend that month and I've come to just ignore the over-budget notifications I get. It's almost like it should allow a range of values for each category in your budget, or auto-flex or something.

So anyway, I have other side projects I am occupied with at the moment, but if you are interested in Moolah or you even have some ideas of your own and you would like to work on it, I would love to make time to work with you on it.

And now on with the README...

## what is it?

Moolah is a very, very simple app I'm building to help me manage my money.

My goals in building Moolah were as follows:

* I wanted my own copy of the transactions that my bank lists on its web interface (because my bank's web site sucks) by being able to download CSVs it gives me and import them straight into Moolah
* I wanted to be able to set categorization rules like Mint so I didn't have to constantly baby the list. This ties directly into the next item...
* I wanted a way to view graphs so I can spot trendlines in my income, get a easy-to-read breakdown of how I'm spending my money (per category), or maybe give me a sense of how I can save it (if I cut back on some expense, etc.)
* Eventually, I would also like to be able to download transactions through my bank's OFX interface, but I'm not sure how to do this (if anyone has experience with this, please let me know).

Also, I wanted to screw around with [Padrino](http://padrinorb.com) and [MongoDB](http://mongodb.org), so this gave me a chance to do both of those while I was at it ;)

## a few notes

So far I have just focused on functionality, so there's nothing pretty to look at yet. But I have the basics down: you can view, add, and delete transactions, and also there are a few graphs (accessible via /graphs right now -- yeah I don't have a link from the main page, sorry).

Since I am building the app for myself, obviously, it is very opinionated. For instance, it assumes the CSV files you are importing have these columns:

1. Transaction Date
1. Check No
1. Transaction Description
1. Debit Amount
1. Credit Amount

Also, it assumes you have a Checking account and a Savings account (although I may customize this in the future).

So I realize you probably have different ideas on what you want a money management app to do, and that's cool. You're perfectly free to use another one, or, if you're so inclined, fork this repo and change it as much or little as you want.

## trying moolah out

Okay! I guess I didn't scare you off ;)

In order to run Moolah, the first thing you will need is MongoDB (all the transaction data is stored in a Mongo database). Don't worry, installing this is easy (I promise). Just go to the [downloads section of the MongoDB website](http://www.mongodb.org/display/DOCS/Downloads) and download the file that's appropriate to your OS. Then, unzip the file and move the folder inside to somewhere like `/opt/mongo` (probably as root). You'll need to run the Mongo server which you can do like this:

    sudo /opt/mongo/bin/mongod --dbpath /data/db run &>/dev/null &

That wasn't so bad, right? You can put that in a bash script or something if you want.

I don't have a gem or anything like that available for Moolah, since I am still working on it. So first, clone the repo to somewhere on your computer (but you probably knew that):

    git clone git://github.com/mcmire/moolah.git
    cd moolah

Now install the gem requirements for Moolah:

    (sudo) gem install bundler
    bundle install

Now, just navigate to the `moolah` folder and run

    padrino start

Finally, open your browser and go to `http://localhost:3000`.

## running tests

Yes, I actually tried to write tests for this ;)

When you ran `bundle install`, bundler should have installed the gems you need to run the tests, so you should be ready to run the tests.

I'm using [Spork](http://github.com/timcharper/spork) to speed up tests. So the first thing you want to do is open up another shell in your terminal, say `spork`, and leave that process running. Then, in your main shell, you can either:

* run the model tests: `rake spec:models`
* run the non-JS acceptance tests: `rake spec:acceptance`
* run the JS acceptance tests: `padrino start -e test -p 5151` (in a third shell), then `rake spec:acceptance JS=1` (in your main shell)

## author/contact

If you've got any suggestions, feel free to send 'em my way! Just send me a Github note or email me (elliot dot winkler at gmail dot com).