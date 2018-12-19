IOM Development Docs
====================
by _Terra Rain_

Legend
------
Here are some acronyms/terms used in this doc (and outside):
  * **MT/MTC**  -- Merchant Tools (classic)
  * **MTA/MTW** -- Merchant Tools App / WWW
  * **ADMT**    -- Admin Tools
  * **Api**     -- Another way to refer to Drinkboard (since its public url is api.itson.me)
  * **WWW**     -- www.itson.me
  * **PV**      -- Purchase Verification
  * **PVCheck** -- PurchaseVerificationCheck model/instance
  * **PVRules** -- PurchaseVerificationRules model/instance
  * **ES6**     -- ECMAScript2015 (v6), aka JavaScript

  * afaik -- As far as I know
  * ofc   -- of course ;)

  * **Comment Markers:** This is my personal tagging system that I use to tag areas of the code for later reference (think TODO/FIXME).  All tags start with `##` followed by one or more markers, such as `##!` or `##j+`
    - `##+ blah`         -- A reminder to add 'blah'
    - `##- blah`         -- A reminder to remove 'blah'
    - `##! description`  -- This indicates the line will cause bug/crash/issue. Can also indicate there's an unhandled edgecase.
    - `##? description`  -- This indicates the line might cause a bug/crash/issue. The line needs research.
    - `##x info`         -- I deleted 'info' from the line
    - `##j description`  -- A comment added by Jon during our "2018 Summit" meeting




List of active bugs, ordered by severity
----------------------------------------
  * hand_delivery purchases do not generate bonus gifts  (seriously no clue why)
  * purchasing multiple items with bonus gifts only sends the first bonus gift.  (technical reason: non-unique proto_id, thrown by: `app/models/proto_join.rb#6..7`, called from line 18: `self.create_with_proto_and_rec(proto, rec)`)
  * Bonus gifts set up on parent/controller menus of multi-redemption merchants send out one bonus gift per menu.  One master plus two slave menus: three bonus gifts.
  * Purchase Verification double-check issue.  I addressed this, but there's still a bug in the method: `app/models/concerns/purchase_verification_rules#already_passed?` (in Drinkboard) -- low priority because it affects very few consumers and is only bad UX; there are no functional flaws present.


Other open priority issues
--------------------------
  * Random ADMT 500s, e.g. when saving merchants.  I suspect this is actually a crash on Drinkboard that gets returned as a generic failure through the ServerWrap API.  I haven't had time to investigate.
  * ADMT cannot redeem hand_delivery gifts.
  * MT users cannot sign up for alerts on MT classic -- it 500s.  Adding the users to the alerts manually is a little tedious (and requires use of the Rails console), and I'm behind on them.
  * MT and Drinkboard memory usage -- removing the "regions update" code from Drinkboard should help somewhat.
  * MT 500s when a user tries uploading images larger than 20mb (uncaught cloudinary upload limit exception)
  * (okay, not a priority) Epson Autoconfigure script -- when last tested quite some time ago, a new Epson printer's configuration (via script/api) didn't "take" unless reset manually once through the web interface.  If this is still an issue in their firmware (needs testing), resolving it requires talking to Epson again and convincing them it happens.  (I've attempted twice and sent them detailed instructions with packet captures and logs for proof, but they always ignored me or never made it a priority.)


Open projects
-------------
  * Onboarding tracker with admin-manageable milestones and APIs for GolfNow to fetch/update  (not started)


Looming problems
----------------
  * Let's start with the scariest first:  All of IOM's backend code (ADMT, MT, Drinkboard) needs a rewrite.  Eventually, due to either a deprecated tech stack (years), the hosting provider mandating an update to x new technology/version that's incompatible with our code (unlikely), or deprecated dependencies due to e.g. security vulnerabilities (the most likely), ADMT/MT/Drinkboard will eventually die.  At some point it will also have security vulnerabilities that might be extremely difficult to fix.  Here's why:  Several years ago, Jon decided that tests weren't worth the effort, and stopped writing/maintaining them.  This means none of the applications have working test suites.  I won't get into the numerous reasons why automated testing is so important, but a single example should serve to explain it pretty well:  The three applications are running quite outdated dependencies, and I cannot upgrade them without breaking portions of the application. Without a test suite to run against the code, there is no way to determine exactly what portions of it will break, except by exhaustive testing after every batch of dependency updates.  This means every update is a gamble, except it's a gamble where you don't actually win anything when you win, but when you lose... the service breaks in at least one way, and you don't know why or how to fix it.  Upgrading all of the dependencies at once would break so much that fixing everything would require basically rewriting much of the codebase.  Also, writing a new test suite from scratch for a codebase that's (completely without exaggeration) ~75% of the length of War and Peace would take so much effort that it also isn't feasible -- especially given how shoddy the code is in so many areas.  The codebase is _maintainable_ as-is, but not preservable.  It will eventually die, and if critical security vulnerabilities crop up, that could very easily be sooner than you'd expect.  To keep IOM alive into the future, the only answer is to rewrite its code.
  * [minor] Speaking of test suites, Surfboard (the application responsible for both the onboarding and ordering sites) is also lacking a test suite.  Given my one-month deadline for the project, I didn't have time to add this, faced stern opposition from Jon at the prospect of adding it, and was inundated with projects afterward, so it just never happened.  However, Surfboard needs pretty limited testing (hosting urls, redux actions, apis), so this would be about two weeks' effort, even given the vastly expanded scope of the project.  Writing this would be a good introduction to whomever takes over the project.
  * RedisToGo is expensive, and the code (on Drinkboard) that updates "regions" vastly exceeds our Redis' server's memory quota, which can lead to the Redis server freezing, thus leading to service-wide outages for IOM (though this hasn't in many months now).  Resolving such an outage requires logging into RedisToGo (via Drinkboard's Heroku dashboard) and manually restarting the Redis service.  Permanent solution: disable the "regions" update code, and migrate to a cheaper Redis provider.  (This task was repeatedly deemed low-priority despite several outages, and replaced with other projects.)
  * The Redemption code generator (which now generates five-digit codes) on Drinkboad will eventually break again.  This is because the system generates unique codes for every redemption, regardless of whether it's needed or not.  Thus, while all possible five-digit codes (89999 possibilities) will take some time to consume, they will eventually be exhausted, leading to another redemption blackout.  Could be a year, could be four years.  `(89999 - Redemption.pluck(:token).uniq.count)` will return how many codes are still available.  At the time of this writing, there are 79873 available.
  * We still cannot pay Canadian merchants without cutting a check (which costs IOM $25 each).  Addressing this will require pouring through the accounting code and possibly rewriting some of it.  Specifically, it needs to send the gift and pay the merchant in the original currency, then transform it from e.g. CAD->USD before paying IOM the remainder.  Some of this work is already done, though as it was over a year ago I can't remember specifics.





Heroku
======
Heroku handles server autoscaling, load balancing, automatic handoff/failover, server/db maintenance, environment variables, credential rotations, etc.  It's basically a very nice frontend service for AWS.  Heroku also provides basic metrics, though they're really not very good.  Heroku also offers a cli tool, which I often use to perform maintenance, such as db updates, maintenance mode, or simple restarts.  Speaking of: Heroku restarts all applications once a day.

All of our (non-mobile) applications are hosted on Heroku, with the exception of the main www.itson.me site. There's a number of applications hosted there, but these are the most important:
  * Admin Tools    (Prod/QA: `admindb`/`admindbdev`)
  * Merchant Tools (Prod/QA: `merchtools`/`merchtoolsdev`)
  * Drinkboard     (Prod/QA: `drinkboard`/`dbappdev`)
  * Surfboard      (`iom-supply-order-pipeline`)
  * Surfboard      (`iom-surfboard-pipeline`)
    - Both of these point to the same codebase; set up this way to host the same application on two different URLs.  (I was never able to get access to DNS)

These are (now) completely unused:
  * iom-ferrari-pipeline  (dropped AdminTools replacement)
  * socket-pipeline       (dropped chat app)
  * itsonmeapi            (I'm assuming this is the server component to the dropped chat app)

The first three are Rails 4 applications, and share a database.

**Admin Tools**, as the name suggests, is the admin interface for IOM.  It hosts tools to perform most actions on IOM gifts, merchants, etc.
**Merchant Tools** is similar, but for merchants.  The code is very old and very very bad; avoid touching it whenever possible.
**Drinkboard** is the backend; it's responsible for everything else.  All purchases, redemptions, notifications, alerts, gift scheduling, ... .
**Surfboard** hosts both the onboard.itson.me and order.itson.me sites.
I'll explain all four of these in more detail later.

In order to deploy new code, follow the instructions on each application's deploy tab on Heroku.  For all but Surfboard, this amounts to pushing to the master branch of application's heroku git repo (which differs from the application's github repo).  Surfboard's Heroku apps (both of them) pull directly from the `production` and `qa` branches of its github repo instead: one `git push origin`, two deploys.



Heroku Addons
=============
**Heroku scheduler:** Allows performing actions (generally `rake` tasks) at specific times and intervals.  These are used for e.g. processing scheduled gifts, sending alerts, expiring redemptions, etc.
**Logentries:** Used for generating alerts from the application logs; has slightly better alert tools than Papertrail.  We're using the free version, so alerts are delayed somewhat.
**Papertrail:** Used for perusing application logs.  Much better UI than Logentries, though slightly worse alert tools.
**RedisToGo:** For Redis, obv.  This needs to be replaced with a different Redis provider, as RedisToGo is the most expensive provider, by far, and offers fewer features.
**Cloudinary:** Provides image storage, CDN, and an extensive transformations/filters/etc. suite.  You can specify crops, color changes, filters, overlays, vignette, format changes, etc. all in the url.
**Librato:**  Not used.



Database
========
The IOM database is running Postgres v10.5.
> n.b.: This version is actually incompatible with Rails 4 out of the box, but I've patched in support.  A long time ago I read about an incompatibility between Rails 4 and Postgres that leads to sporadic timeouts, which matches what I see in the metrics. I've never been able to verify this, however.  (Also, I could not upgrade to Rails 5 due to outdated dependencies and the lack of a test suite.)  Interestingly, abandoned (yet still running) rails test applications with no traffic, like `itsonmeapi` also exhibited the sporadic timeout issue.

The same database is shared across Drinkboard, Admin Tools, and Merchant Tools.

See the Database Schema section at the end of this document!



Maintenance
===========
I've been making a weekly backup of the production database every Monday (and/or prior to migrations/releases/fixes).  This is listed as the WHITE db on Heroku.  To perform a manual backup, go to the resources tab of Drinkboard's Heroku page, click on the `Heroku Postgres :: White` add-on, then click on the Durability nav link, and finally on the [Create Manual Backup] button.  Alternatively, you can perform the backup using the Heroku CLI and automate it however you please.  (I wrote a crontab for it.)

Here's the commands for Production:
  * Perform backup: `heroku pg:backups:capture  DATABASE_URL  --app drinkboard`
  * Download most recent backup: `heroku pg:backups:download  --app drinkboard`
  * Import: `pg_restore --verbose --clean --no-acl --no-owner -h localhost -d drinkboard_dev ./latest.dump` 

For QA, replace `--app drinkboard` with `--app dbappdev`.  Also, you will need to replace `-d drinkboard_dev` in the import command with whatever you named your local database.


There are also two sidekiq queues to monitor for job failures:
  * https://api.itson.me/resque/failed
  * https://qaapi.itson.me/resque/failed

> FYI: The "retry" feature doesn't always seem to work.


Surfboard also needs periodic dependency upgrades (and really needs a test suite, which shouldn't take too long to write).  Refer to the Surfboard section if you run into any npm/dependency issues.


Logging
=======
There are a lot of different forms of logging in use currently.  The majority of log entries are just random messages that don't give any real idea of where they're coming from, and only some indication of what they mean.  Many of these also include hardcoded line numbers (that obviously don't continue to match up).  This leads to needing to learn what each message means and search the codebase to see where it's coming from. The previous pattern (and current, I suppose) is to include the string "500 Internal" within log entries, which then triggers Logentry's (and Paptertail's) email alert system.  This leads to "500 Internal" appearing in a lot of non-crash messages.
  
As I've refactored code, I've been migrating the log messages to my format instead.  Take it or leave it, I find it much more informative and easier to read.  Here's the format, including a sample error message, and also an example taken from the code:
  `\n[type Path::To::Object(hex_id||id) :: method(important_arg:value)]  Error: Too Beautiful`
  `\n\n[api Web::V4::SocialsController :: set_primary(#{params[:social_id]})]`
The first is an example of an instance method erroring (`Object` has a hex_id or id), while the second is a class method (no instance id) being called with the given `social_id` data.  This format shows everything you need to know: exactly which object, which instance, which method, which [important] arg(s), and what happened.  I also started adding newlines to the signatures to help improve local logging readability (I say 'local' as these newlines are not displayed in Heroku logs).  I add two newlines for the method's first log entry, and one for any additional entries.  This helps visually group the call flow.  (A nesting logger would be better, but beyond the scope of this simple debugging)

For multi-part log entries, I put each additional portion in another entry with a nesting separator (` | `) so it's obvious they're nested under the initial log entry.  ex:
```
[type Path::To::Object(id) :: method(arg:value)]
 | relation: hex_id
 | status update
 | status update
 | result
```
In this way you can search for the method signature in papertrail, see a list of entries to scan through, click on the one you want to examine, and see what happened in much more detail.  A potential downside of this approach is Heroku's out-of-order logs, but in practice it's rarely an issue.


Here are some pointers for searching through the logs:
In Papertrail, you'll find these queries the most useful:
  * `status=5`  --  This finds 5xx error responses.
  * `.rb`       --  This (usually) only appears when Ruby crashes and prints a stack trace.  It's also present in some older log messages.
  * `]  Error`  --  This matches the error string from my method signature format.
  * ` :: `      --  This finds all method signatures.  Not the most useful, but can help when you don't know which signature you're looking for.


Something else I should mention about the logging: There is an incredible amount of log spam.  I've been trying to make time to clean this up for eight months or more, but other things have always taken priority.  A notable example is the Epson log spam: they generate so many entries so frequently that it makes the logs very difficult to follow.  There are also a *lot* of alert emails being generated, and very few of these are useful, or even interesting.  So, while looks scary, it's just annoying at best.  It also floods your inbox...



Warnings
========
While there are three separate applications (Drinkboard, ADMT, MT), there is a *lot* of code duplication and divergence between them.  Changes on Drinkboard often need to be migrated to ADMT (and vice-versa) or things may start breaking or not working correctly.  This is somewhat true of MT as well, but it's so old with so little functionality that it often isn't necessary.

There are no test suites.  If you find one and it claims to be a test suite, don't believe it.  They are all very outdated and useless at best.  (Check the timestamps in git blame)

The dependencies are also outdated.  Due to the lack of a test suite, updating the dependencies is always a gamble.  Maybe nothing broke.  Maybe something broke and you didn't catch it.  or maybe the upgrade slightly altered the application's behavior and you won't notice until it makes a mess on the carpet.  If you're lucky, it'll break in a very obvious, easily-fixable way.

Also due to the lack of a test suite, upgrading to Rails 5 is basically not going to happen.  The upgrade would break a lot of things, and would also require a host of dependency upgrades, which would break more things.  No test suite means no insight into what breaks (or worse: no longer functions correctly), which means weeks to months devoted entirely to debugging.

Promises made outside of ES6 will not resolve.

Much of the code is ... kind of terrible.  It works, and works pretty well, but it's terrible so I've sadly avoided any unnecessary refactors.  (And there's a *lot* of it!  Drinkboard alone is half the length of War and Peace!)  Most of the code is deeply nested, uses magic constants, and has poor, confusing, and/or lazy naming conventions.  It can be difficult to follow exactly what the code is doing without wider knowledge of the system.  Also: all codebases (except Surfboard) have mixed indentation.

One of the more infuriating coding patterns used (even moreso than the mixed indentation) in MT/ADMT/Drinkboard is the `if (var = method)` antipattern; this runs `method` and skips the block if its return value is falsey.  While it's admittedly useful, it's unexpected, unintuitive, and has caused bugs more than once.  I've refactored many of these out already.  If you see this in use, be extra careful when refactoring.

Surfboard has one security vulnerability with breaking changes (CVE-2017-16042); I haven't had time to address this.  Given the nature of Surfboard, however, I'm not really concerned.



Dev Env
=======
You will need to install git, Postgres (v10.5), and Redis (I'm using v5.0.1).

(If you're working on a Mac, the first thing you need to do is install the XCode console utilities (or whatever they're called), and then Brew.)

After that, clone the applications from ItsOnMe's github.
  * https://github.com/ItsOnMe/drinkboard.git
  * https://github.com/ItsOnMe/admintools.git
  * https://github.com/ItsOnMe/merchantTools.git
  * https://github.com/ItsOnMe/Surfboard.git
    - To build and run this application, refer to the Surfboard section later on in this document.

If you care, there's also an Epson printer autoconfiguration script I started.  It's hacky, though, fair warning.
  * https://github.com/ItsOnMe/Epson.git



Running applications locally
----------------------------
First off: I highly recommend setting up RVM, as each of the three Rails applications use a slightly different version of Ruby for no particular reason.

These applications are configured to communicate (locally) over specific ports:
  * Merchant Tools: `3000`
  * Drinkboard: `3001`
  * Admin Tools: `3002`

It goes without saying that running the applications on different ports will cause any apis to fail.  I've included some of my bash aliases at the end of this file to make this easy.


Shared
======
This section covers concepts shared across the applications:




Hex IDs
-------
Most models include the HexIdMethods helper, which adds unique hex_id generation on record creation.  The helper looks for a three-character `HEX_ID_PREFIX` constant defined on the model.  Basically, a hex_id is a prefixed hex code that works in place of a numeric ID.  When looking at `rd_badc0de` you immediately know it's a redemption; likewise `gf_c0ffee` is a gift.  Generally, all displayed/viewable IDs should be hex_id's whenever possible, not primary-key integers.

You can look up an object instance by its hex_id with the helper functions `where_with(hex_id)` and `find_with(hex_id)` -- I have no idea why the method names are so unclear.


ServerWrap
----------
ServerWrap is a basic api wrapper that allows the ADMT/MT to call functions on each other, or Drinkboard.
(Drinkboard has no need to call the other two applications, so it does not exist there.)

I don't think I need to explain this very much as the system is very simple.  It provides methods that perform API calls to the other applications.  This reduces code duplication (or would if everything wasn't copied anyway), but certainly adds overhead.  It can also make some actions extremely difficult to follow, such as the ADMT MerchantSignup-to-Merchant promotion: that action jumps between all three applications and back!




Admin Tools (ADMT)
==================
This is the admin interface (obviously) for IOM.  It provides GUIs for most actions on gifts/redemptions/merchants/affiliates/etc., setting up alerts, tracking printers, basically everything.

Admin users are stored in the at_user table, so if you need access, that's where you add yourself.


ADMT is too large to describe in detail, but here are a few of the things other people won't be able to explain or that you should/need to know:
  * **User Access:**
    - The codes are generated in `app/models/UserAccessCode#generate` in Drinkboard, and will eventually run out.  I hacked the generator together in an hour or so, but you should be able to extend it without much effort.  Adding a handful of new words or a new format will greatly increase the available codes.  You can also delete any existing unwanted/unused codes, ofc.
    - The controls to generate access codes are only visible on the User and Merchant pages (meaning it is missing from affiliate pages).  You'll either have to generate these manually or write the UI for it yourself.
  * The migration tool for migrating from any redemption-system to Clover doesn't work correctly (as I remember it migrates the merchants backwards.)
  * The "ADMT dashboard" (aka ADMT's first page) is in the "static" controller
  * ADMT is not responsive and renders horribly on mobile.  This is very difficult to remedy due to the sheer amount of inline styles, and no real use of stylesheets.  I'm kind of guilty, too, for continuing this travesty.




Drinkboard (API)
================
This is the primary backend codebase.  It performs basically everything: all purchases, redemptions, notifications, alerts, gift scheduling, etc. The only frontend portions are the gift acceptance page and "printed cert" PDFs; possibly a few other one-off pages.

The codebase is huge and, due to haphazard direction and inexperienced development, there are a lot of unnecessary features and deprecated code, so there is a lot to cover.

First, though: Drinkboard has memory problems.  This can potentially be mitigated somewhat by disabling the now-unused merchant regions update code (redis).  Beyond that, I don't know.



APIs
----
While these APIs are "versioned," the "version" is, at best, a very loose grouping. It has nothing (or almost nothing) to do with versioning.

Specifically:
  * `web/mdot` -- deprecated; was for mobile only.  ("mdot" literally stands for "m." in m.itson.me)
  * `web/v1` -- only for email confirmation (possibly deprecated)
  * `web/v2` -- only for fetching merchants (possibly deprecated?)
  * `web/v3` -- contains the vast majority of the functionality; used by everything: widgets, mobile app, ADMT, etc.
  * `web/v4` -- permissioned endpoints, used exclusively by MTA


Access Grants
-------------
This is the permission system used by MTA and all of the v4 APIs on Drinkboard.

Terminology:
  * Grant: instance of UserAccess -- grants a user a level of access (determined by role) at a Merchant/Affiliate.
  * Code:  instance of UserAccessCode (or the actual string, e.g. "bent fish")
  * Role:  instance of UserAccessRole (or its associated symbol / integer access level, e.g. 2 for `:admin`)

An access grant allows a user a certain level of access to a merchant, or to all merchants associated with an affiliate.  This level is determined by the UserAccessRole associated with the grant.  The highest access level obviously takes precedence.  Any action can of course be restricted to specific access levels, such as via:
> `@current_user.highest_access_level_at(merchant) >= UserAccess.level(:manager)`

Access grants can also be moderated, meaning they require approval from the next higher role, or an admin (employee<-manager<-admin, manager<-admin, admin<-admin).  This moderation helps prevent someone guessing access codes from gaining access to merchants.  Completely up to the merchants to do, however.

Merchants can have custom UserAccessRoles, but there are only three permission levels so custom levels only really amount to customized titles.

**Warning:** `UserAccessCode.generate` generates unique codes; however, these will eventually run out.  (See below)
**Warning:** Access levels' integer values are generated via indexes from hardcoded arrays located here: `app/helpers/user_access_helper.rb#access_level` AND here: `app/controllers/web/v4/associations_controller.rb#user_access_levels`.  If you need to expand or alter these roles, you must change them in both locations (and please move it into `config/initializers/constants.rb`) and also make sure to create UserAccessRole records for any new roles you add!
**Caveat:** Access codes are currently case-sensitive (and always lowercase); super simple fix.


**Notable files:**
  * `app/models/UserAccess.rb`
  * `app/models/UserAccessRole.rb`
  * `app/models/UserAccessCode.rb`
  * `app/helpers/user_access_helper.rb`
  * `app/models/user.rb`
  * `app/controllers/web/v4/*_controller.rb`


**Notable methods:**
  * `UserAccess.grant_for`
    - When passed a user_id, a role, and an owner (both role/owner either via an instance or type/id pair), this method creates and returns an (unsaved) UserAccess grant.  The `owner` arg here means the Merchant/Affiliate the grant is allowing the user access to.
  * `user.highest_access_level_at(owner)`
    - when passed a Merchant/Affiliate, returns the user's highest access level (as an integer).
  * `UserAccess.level(role_symbol)` and `userAccessRole.level`
    - returns the integer level for the given role (none:`-1`, employee:`0`, manager:`1`, admin:`2`).  This allows for very simple integer comparison of access levels
  * `UserAccessCode.for` -- Returns an (unsaved) unique UserAccessCode instance when passed a role (UserAccessRole instance or id), owner (either Merchant/Affiliate object or type/id pair), and a `moderate` bool


You can also generate the code strings directly using `UserAccessCode.generate(format:nil)`
  * This generates and returns a new (unsaved) access code, using the given format if specified, or picks a pre-defined format at random.
  * Example formats:
    - `[:three_alpha, :three_alpha]`  ex: "abc def" -- randomized, so it can generate phrases like "top kek"
    - `[:number, :adjective, :noun]`  ex: "thirteen boiled napkins" (😂)
    - `[:adjective, :noun]`  ex: "sad fork"
    - `[:number, :noun, :comma, :number, :noun]`  ex: "five fish, twelve pots"
    - `[:number, :noun]`  ex: "three envelopes"
  * Nouns are pluralized using the most recent number, e.g. two beavers, one pot
  * I hacked the generator together in an hour or so, but you should be able to extend it without much effort.  Adding a handful of new words or a new format will greatly increase the number of potential access codes.  You can also delete any existing unwanted/unused codes, ofc.
  * Nouns and adjectives are generally food-related.  Take care when adding new words, however, because the combinations aren't always the best.  Example: the noun 'local' (as in “locals” and “gift local”) makes a bad addition because of generated strings like "three (hot|spicy|saucy|boiled) locals"
  * I intentionally stopped using `:comma` in the active formats to simplify entering the codes.


"Resources" url
---------------
This exists to serve assets used elsewhere in the IOM system, or for merchants.  Examples:
  * QR Code generator
  * Static documents like instructions for merchants

It didn't get much development love, so there isn't a lot of functionality present.


Redemption Spaghetti
--------------------
At a high level, a redemption is an action performed on a gift to allow a customer to use some or all of its value.  This can be a simple debit for `x` cents, or a printed cert that's good for the gift's full (current) value.  Note that the latter does not _reserve_ value from the gift, and merchants are able to look up a gift's remaining value.

The file `app/models/redemption.rb` defines a Redemption object.  The file `app/models/redeem.rb` defines how redemptions are redeemed -- and that's the real spaghetti.

For redeeming... Well, first off, there are eight separate redemption systems.  Eight.  They're most often identified by their number (at least in code).  The redemption system is referred to as `r_sys` throughout the code.  Here are what its possible values translate to:
  1) **v1:**  redemption
  2) **v2:**  redemption  (used by merchants via MT/MTA)
  3) **Omnivore**
  4) **Paper:**  (this includes both paper certs and hand_delivery certs)
  5) **Zapper:**  (Buggy QR code system used by like two merchants)
  6) **Admin:**  (ADMT redemption)
  7) **Clover:**  Clover tablet integration.  Richard Meyers is responsible for the clover app.
  8) **Epson:**  Epson printers.  When a gift gets redeemed, the merchant's printer automatically prints out a receipt.  Sweet.
(These are also [mostly] defined in `config/initializers/constants.rb` line 152: `REDEMPTION_HSH`)


Here is where each redemption type starts:
  1) **v1:**   ???
  2) **v2:**  `app/controllers/web/v3/gifts_controller.rb#start_redemption` and `#complete_redemption`  (`app/controllers/web/v4/...` for MTA merchants)
  3) **Omnivore:**  `services/omnivore.rb`
  4) **Paper:**  `app/controllers/web/v3/gifts_controller.rb#start_redemption` and `#complete_redemption`  (`app/controllers/web/v4/...` for MTA merchants)
  5) **Zapper:**  `services/ops_zapper.rb`
  6) **Admin:**  ???
  7) **Clover:**  `services/ops_clover_api.rb`
  8) **Epson:**  `app/controllers/web/v3/gifts_controller.rb#start_redemption` and `#complete_redemption`  (`app/controllers/web/v4/...` for MTA merchants)

From there, they call methods in `app/models/redeem.rb`, and many of them branch quite differently amongst the various methods.  You will have to follow each one yourself to understand the flow; I honestly can't remember them well enough to describe.  For reference, and to explain why I call this "redemption spaghetti," here are the internal Redeem methods that can get called (listed in the order they're defined):
  * `Redeem.rb#partial_redeem_redemption`
  * `Redeem.rb#start_redeem`  Calls `start_apply` for Epson, `start` for everything else.
  * `Redeem.rb#complete_redeem`  Calls `complete` for Epson, `apply_and_complete` for everything else.
  * `Redeem.rb#start_apply`  Calls `start` then `apply` (on success)
  * `Redeem.rb#apply_and_complete`  Calls `apply` then `complete` (on success)
  * `Redeem.rb#apply`  This is where the redemption's value is deducted from the gift
  * `Redeem.rb#epson_redemption`  Generates print queues for Epson
  * `Redeem.rb#internal_redemption`  Used by v1, I believe?
  * `Redeem.rb#omnivore_redemption`
  * `Redeem.rb#zapper_sync_redemption`
  * `Redeem.rb#zapper_callback_redemption`
  * `Redeem.rb#complete`  Too much to summarize
  * `Redeem.rb#start`  Too much to summarize

Epson redemptions do not complete until the printer has fetched its print queue.

A very odd quirk I should mention: `app/controllers/web/v3/gift#complete_redemption` calls `Redeem#apply_and_complete` and uses its return type (not value) to determine if the redemption succeeded or not.  This form of error checking is sadly quite common in the codebase.

There is also a bug around the `case redemption.r_sys` block of `Redeem.rb#apply` (Line 227) -- the Epson block following it causes harmless "redemption sync errors" (logged within `app/models/print_queue.rb`).  As I remember, the fix is to queue the redemption first, though I think there was something else, too.  Jon advised me on this during our "2018 Summit" meeting, but again, I never got to finish and test this, so the bug (and therefore debug log entries) remain.



Clients
-------
Clients are API consumers.  These include Clover devices, widgets, Epson printers, IOM iOS/Android mobile app, Surfboard, etc.  The `application_key` column is the client's API key.

If an API request does not provide an API key, an error message appears in the log, specifically: `No 'HTTP_X_APPLICATION_KEY' - authenticate_client TRAINING WHEELS`.  This is generated from app/controllers/metal_cors_controller.rb

Interesting: clients contain a "clicks" column that gives a general indication of usage amount.  It's not terribly reliable as a metric, though, as it can increment multiple times for a single interaction (depending on the type of usage).  Example: a widget gets a 'click' for each http request made using the key.


Printers
--------
Epson printers are wonderful, and fit IOM's business friggin' perfectly!  They are also terrible to work with.
Merchants also have NO BLOODY IDEA how to keep a printer a) plugged in, and b) full of paper.  Absolutely beyond their ability.  Why? They're friggin' morons!

I build a semi-crude tracking system for the printers.  Here's a link: https://admin.itson.me/epson_printers
Every ~30 seconds, printers poll our server to fetch their print queues.  As this is a lot of DB writes, the tracking code only updates the printer's "online" timestamp during a 45-second window every six hours.  (This could easily [and should] be lowered to every 4 minutes; it's defined here: `config/initializers/vars.rb` line 251: `EPSON_TRACKING_SECONDS_BETWEEN_POLL_CAPTURES`.)  Each printer also sends us an update (also once every 4 minutes) including bitflags that indicate their status, such as low paper, cutter errors, or mechanical failure.  I extract this info and update timestamps accordingly, and display everything nicely on the tracking table.  Each printer on the table is sorted by its "squeakiness" -- how much attention it needs.  Offline (those that have missed 2 polls) adds the most squeakiness, followed by current mechanical errors, followed by out of paper, followed by ... you get the idea.

Tracking defaults to `nil` for new printers, which means the tracking code will auto-enable tracking on the printer's second IP change (first: initial ip while configuring, second: new ip from installation at a venue).  However, this does not work and I have been unable to determine why.  I've seriously looked at that code thirty+ times, and shown it to several other devs.  If you figure it out: **good for you!**  ... and then tell me what was wrong >.>;  Here's the location: `app/services/print_epson_responder.rb` lines 84..94

There is currently no way to enable/disable tracking via ADMT; you must do so via the Rails console.  Here's how: open the console and type `EpsonPrinter.find(id).update(tracking: ?)` where `?` is...
    * `nil`: auto-enable tracking on its next IP change (bugged)
    * `true`: enable tracking
    * `false`: disable tracking

Printers with tracking disabled do not update any of their tracking info.

There is also no way to delete printers from the list, so you need to do that manually, too.  Just find the printer record and destroy it like so: `EpsonPrinter.find(id).destroy`. Note, though, that if the printer is live (as in actively polling), the record will just get created again.


The printer tracking also has (disabled) a recall feature. If there's no way to determine which merchant/client an active printer is tied to, or if the printer reports itself as faulty, the system creates a printer_recall record for that printer.  The existence of this record tells the printer to print a recall notice (saying the printer is either misconfigured or faulty depending on type) once every 24 hours (or every 2 minutes in qa).  This notice tells the merchant to contact ItsOnMe for a replacement.  Again, this feature is currently disabled, and has never been used in production.



Speaking of receipt printing:  Epson printers accept a blob of XML that describes how to print one or more receipt, what actions to take (such as feed paper, cut `x` width, ...), etc.  Looking through the files below will give you a good idea of how this works.  Warning: Depending on the firmware version the printer is running, however, some features may not work at all, and unicode characters can cause the printer to crash.


**Notable files:**
  * Printer recall
    - `app/services/print_recall_faulty.rb`
    - `app/services/print_recall_misconfiguration.rb`
  * XML for specific print jobs:
    - `app/services/print_redemption.rb`
    - `app/services/print_shift_report.rb`
    - `app/services/print_test_redemption.rb`
    - `app/services/print_help.rb`
  * Epson XML helper methods
    - `app/services/print_utility.rb`
    - `app/services/print_xml_footer.rb`
    - `app/services/print_xml_header.rb`
    - `app/services/print_xml_recall_footer.rb`
    - `app/services/print_xml_recall_header.rb`
    - `app/services/print_xml_title.rb`
    - `app/services/print_xml_wrap.rb`
    - `app/models/concerns/epson_xml_helper.rb`
      - This one looks unused.  It's also in an odd location.




Paper and hand_delivery certs
-----------------------------
Both of these gift types generate a PDF the user can print out and use themselves or give away.  A hand_delivery cert differs from paper certs in that they're meant for the purchaser to hand deliver to the recipient, and so includes their personal message, etc.

The PDF generation code lives in `app/controllers/papergifts_controller.rb` and uses the `wicked_pdf` gem/binary.  The routes are extension-aware, meaning you can specify .html instead of .pdf in the url to render the cert in html instead.  This is useful for debugging and faster generations while devving.

When creating either type of cert, the system generates a redemption for the gift.  This is necessary because merchants need an rd_code to redeem gifts.


Accounting
----------
I've barely looked at any of the accounting code, so I don't know this part of the system well enough to document.

The only thing I can really say is that `Registers` are undeletable accounting line-items (credit/debit), named after check registers.

There is, however, the issue where we cannot pay Canadian merchants the same way as American merchants without cutting a check for $25 each.  To recap:
> Fixing this issue requires sending the gift and paying the merchant in the original currency, prior to transforming it to USD and paying IOM the remainder.  Some of this might already be done, but I can't remember because I looked at it over a year ago.




Merchant Tools (MT)
===================
This is what most merchants see and use, and is their only source of reports.  The reports aren't great, and at least some of them are old enough to not support e.g. gift partial redemption.  Some of them show differing information.

Very much a legacy codebase; the code quality is horrendous, meaning even simple features/fixes can take days.  The sidebar alone is an untamable beast sprawling across, without exaggeration, 15+ files (many of which are identically-named) and 50 pages of code.  Uses Devise (ugh) and standard Rails validators.  If there's an error displayed somewhere you can't find, look [carefully] through the validation methods.

MT interacts with ADMT and Drinkboard via "ServerWrap" and (fair warning) consumes some custom APIs that behave differently than the APIs used by everything else.
MT users are stored in the `mt_user` table with their own password digests, created with a different "rails secret" -- meaning Drinkboard very likely cannot compare passwords against them.  MT User passwords are therefore stuck in MT and cannot be migrated.  (That's why I built the v4 APIs for MTA that use normal user accounts instead)




Surfboard
=========
This application runs both onboard.itson.me and order.itson.me, rendering a different view depending on the url the user visits. This is to avoid code duplication since both sites are very similar and would share 80%+ of the same code anyway.  I wrote it in ES6 using the webpack transpiler, Express.js for its webserver, and the React framework (with Redux).  It also uses Susy for a CSS grid, and Sassy CSS for styles.  I finished the first release of this application in three weeks, without knowing anything about React, Redux, Webpack, Express, Susy, etc.  I'm incredibly proud of that.

Despites the same application serving two separate "sites," Surfboard is actually hosted via two separate applications: the two heroku pipelines: `iom-supply-order-pipeline` and `iom-surfboard-pipeline`.  Both of these are pointed at the same github repo, meaning they run the exact same code.  I had repeatedly requested access to the DNS, and was always ignored/redirected/etc., so this is the best I could manage.  Costs more, but it works. 🙄

Deploying is almost too easy: the QA and Production sites autodeploy from branches of the same name, so `git checkout production && git merge master && git push origin` is all it takes.  See Surfboard's readme for more information on this and the branch layout!


**Onboarding:**
  * Submits credit card info to Stripe and passes a token to Drinkboard
  * Consumes Drinkboard APIs to create a MerchantSignup record, which gets automatically promoted to a paused Merchant
  * when Surfboard sees `?affiliate=golfnow` in the url, it displays a GolfNow view with rather different behavior.
    - Different Welcome/Venue steps, automatic plan selection, different handling within the CheckoutSummary step, etc.

**Ordering:**
  * Fetches its item list from drinkboard (the supply_items table)
  * Allows purchasing multiple items
  * Submits credit card info to Stripe and passes a token to Drinkboard
  * Tells drinkboard to create an entry in the supply_order table

Organizational notes:
  * The larger "flow" components live in the "views" folder (e.g. onboard, order)
  * Shared components are in "partials"
  * Everything else lives in "components"
  * Components can have sub-components, which naturally live nested inside their parent components.
    - components/foo
    - components/foo/bar
    - ...
  * I started namespacing the redux actions to avoid naming collisions as the application grew, and to make both reading and including them easier.  These aren't true namespaces, essentially just adding them actions to a generic (exported) object instead, but it works just as well. I never had time to finish this, which is why Ordering actions are namespaced but Onboarding actions are not.
  * Each component has its own scss stylesheet, each of which are included in the parent view's stylesheet (such as onboard).  If your styles don't apply, make sure you've included your sheet in the parent.  The styling folder structure should be more or less identical.
  * I've included comments explaining some of the more confusing things, such as magic methods added by ReduxForms, the correct decoration order of components (which might be in a commit message instead...), etc.  If you're confused about some of the code, be sure to check the commit history, too.


### Dev notes
I wrote startup scripts (for dev, qa, broken-qa, and prod) to make building and running the application easier.  These set the various API credentials and set `NODE_ENV` so Surfboard points itself at different Drinkboard servers.  The broken-qa script runs with invalid credentials for testing responses to those.

Here's an example QA script with the credentials removed:
```
#!/bin/bash

export NODE_ENV=staging
export APPLICATION_KEY=cl_xxx
export ONBOARDING_TOKEN=xxx
export ORDERING_TOKEN=xxx
export STRIPE_API_KEY=pk_test_xxx

npm run start
```

(Other `NODE_ENV` values are `development` and `production`)


Also: Hot reloading **does not work**.  Jon managed to make it work after about a week of fighting, but didn't share how. (Seriously?!)  However, restarting the build script is quick and easy enough that I never cared much.


**If Surfboard will not build due to dependency issues:**  This is very likely due either to NPM killing itself or deciding to silently update some (but not all) arbitrary sub-dependencies all by its lonesome.  If it's the latter, run `npm update --depth 9999` to force-update everything and its 2^13th great-grandmother, go make lunch (seriously; it takes ~15 minutes), and then try the build script again.  While that should work, if that doesn't, run `npm install` afterwards to make sure the updates actually got installed.  Should that fail as well, just reinstall npm.  If you've added a dependency recently, it could be due to NPM failing to install an arbitrary sub-dependency (old, known npm bug); the only remedy I know of is to determine which sub-dependencies are missing and add them to package.json as a top-level dependency.  This forces npm to install them.




MTA/MTW
=======
MTA is the "new" merchant tools.  It lives in the mobile app (MTA for MerchantTools-App) and on www.itson.me (called MTW there); both of these are different frontends for the same backend: the permissioned v4 APIs on Drinkboard (plus some v3 for the remaining functionality).

It allows managing users and access codes, and approving/denying moderated access grants.  It also allows merchants to redeem gifts via both QR code and typing in an rd_code.  The plan was to migrate all of MerchantTools classic (MT) to MTA, and migrate all merchants over to the new version, but that was never deemed a priority, so now it's half-implemented (or less) and merchants need to have two different accounts to use their tools.

This needs merchant->consumer gifting, keyword campaigns, menu CRUD, menu linking, bank info editing, description editing, banner/logo uploading, alert signups, (rewritten) reports, etc.

*(for Brandon to add to)*




Mobile app
==========
(for Brandon to populate)




Widgets
=======
(for Brandon to populate)




www.itson.me (www)
==================
(for Brandon to populate)





Processes
=========

Alerts
------
Jon documented the alert system -- probably the only documentation he wrote.
You can find it here: alerts/_alert_explanation.rhtml

You should also look at `app/alerts/golfnow_merchant_submitted_sys_alert.rb` for a better example of how to generate both html and sms alert text without duplicating code.  (The summary: always generate markup, and for sms alerts: replace spacing/decoration tags like <br/> and <hr/> with text, and strip out the rest.)

Fair warning: the alert views on ADMT run hundreds of queries per page, and so will often timeout.  I never had the opportunity to address this after discovering it.


Gift Purchase
-------------
This starts at `app/controllers/web/v3/gifts#create` which creates a new `Gift` record via `GiftSale`.  This is unintuitive, as `GiftSale` inherits from `Gift`, and therefore does not have a database table.

When purchasing gifts, the system stores the `rec_net` (or: recipient network) the user chose.  This is a two-character string indicating how the user chose to send the gift.
  * `ph` Phone
  * `em` Email
  * `hd` Hand_delivery
  * `tw` Twitter
  * `fb` Facebook
  * `io` Admin/ItsOnMe (Unused afaik)


Gift Delivery
-------------
This is done primarily via either Twilio or Mailchimp.  (There are also Twitter and Facebook, but these are deprecated.) Twilio is located here: `app/services/ops_twilio.rb`.  Email is spread out over `app/mailers/*` and `app/bookings/email_bookings.rb`; however, I haven't touched this area like at all.


Push Notifications
------------------
I don't know this part of the system at all.  I've done minor debugging, but no further.
One of the files is `app/services/urban_airship_wrap.rb` -- which is odd because afaik the system doesn't even use the UrbanAirship integration anymore.


Redemption
----------
See (Redemption Spaghetti)[#Redemption%20Spaghetti]


Purchase Verification
---------------------
PV should actually be called "pre-purchase verification" or even "user verification" because it's an anti-fraud tool.
The widgets and mobile app both support the new functionality; however, older versions in the wild don't call the PV apis, and therefore bypass it.

Purchase verification performs a set of rules against an attempted purchase (or really any data at all) and either allows the purchase, prevents the user from purchasing again for awhile (a lockout), or requires the user to pass one or more checks.  Currently the system only supports SMS code checks (so IOM can collect potentially fraudulent phone numbers), but this is easily extensible.

Each purchase verification check (PVCheck) has an associated severity.  A number of failed checks whose tallied severities exceed a threshold (currently 100) triggers a lockout, which then blocks all purchase attempts from the user for 30 minutes.  This lockout is also stored permanently in the user's PV history, is included in the daily report, and is viewable in both the dashboard and fraud table in ADMT (https://admin.itson.me/recents and e.g. https://admin.itson.me/users/30003/fraud?user_id=30003).  Users also get partial credit for passing checks, so large numbers of checks are a little more forgiving.  Severities and the lockout threshold are defined near the top of the PVCheck model (`app/models/purchase_verification_check.rb`).


Notable files:
  1) `app/controllers/web/v3/gift_controller.rb`  -- the v3 gift apis
  2) `app/models/purchase_verification.rb` -- finding, creating, reporting on PVs; also the entry point for verifying PVChecks.
  3) `app/models/purchase_verification_check.rb` -- creating and verifying PVChecks, also methods/scopes for reporting
  4) `app/models/concerns/purchase_verification_rules.rb` -- defines and runs rules against a purchase attempt

Notes:
  1) This feature still contains debug logging.
  2) This makes heavy use of dynamic function calls.  While a little confusing at first, this keeps things short and nicely separated, and reduces code duplication.  (Why dynamic calls?  I had a week to design and build the PV system, and this was the quickest approach to make everything modular. If you want to separate the concerns a little better using modules instead, feel free to refactor it.  I didn't have enough time.)
  3) The method `PVRules.already_passed?(check_type)` does not work correctly, and therefore can present users with duplicate check types, in other words users may have to enter two separate SMS codes.  This is the reason the :first_large_gift rule is disabled in production: first-time users purchasing a $200 gift trigger both :large_gift and :first_large_gift, leading to two SMS code checks.  Fixing this minor bug has never been a priority, so the rule is disabled instead.
  4) All purchase attempts generate a PV record, regardless of whether or not that attempt triggered any PVRules.  This makes PV reports significantly easier to write and less expensive to run.
  5) PurchaseVerification records keep track of their check_count via an after-save hook.  This cuts out a join and therefore speeds up queries quite a bit.  It's also useful for metrics/reporting.
  6) Admin lockouts have their own lockout rules (`admin_lockout`, `admin_rescind_lockout`) and a session_id that includes the admin's id, name, and timestamp.  They are also logged on ADMT.
  7) Expired PVs don't count against the user in any way.  They are, however, an indication of a lost sale (or a potentially fraudulent purchase), so these are included in the daily report and the ADMT dashboard.
  8) All PV actions extend the PV expiry timer, making it impossible for a user to have their purchase expire if they're actually doing anything.
  9) Users that don't have phone numbers trigger a :defer status, which has a 1-hour expiry.
  10) There is currently no fallback from SMS to e.g. IDology, as the only implemented check type is SMS.  (IDology was never made a priority.)


Here's the API/code flow: (detailed)
  1) A user fills their shopping cart on the app/widget
  2) The widget calls `app/controllers/web/v3/gifts/verify` with the supplied gift purchase data, which includes a session_id generated by the client app/widget.
  3) `app/controllers/web/v3/gifts/verify` calls `PurchaseVerification.for(@gift_hash)`, which finds or creates a PV record for the session
  4) It then calls `perform` on the PV record.  (This method lives within app/models/purchase_verification_rules.rb) this method runs all of the Purchase Verification rules against the purchase.
  5) `perform` returns a hash with `verdict`, `success`, plus optional data such as `type`, `phone_number` `msg`.  All of this (with the exception of `success`) is sent back to the client.  The most important param here is `verdict` which tells both system and client if the user is allowed to purchase the gift, needs to perform a check, or has been locked out.  `success` is a pass/fail flag used internally to simplify the logic elsewhere; it is discarded before being sent to the client.  This could be cleaner, but I had a week to design and write this.
  6) Depending on `verdict` the system returns various responses to the client (expired, failed, lockout, success, check).
  7) The client collects the requested information from the user, and supplies it to the server via the `app/controllers/web/v3/gifts/verify_response` API
  8) That API looks up the PV object, and then calls `pv.verify_check(response)`, which ultimately calls `verify` on the user's most recent PVCheck.
  9) `PVCheck.verify` checks for a failed/expired/deferred PV, and calls `syndicate_verify`, which calls the approprite verify method for that check type (e.g. `_verify_sms`).  The verify methods verify the user's response, update the check accordingly (pass/fail/etc), and returns the verdict back to `verify`.
  9a) If `verify` receives a pass, it returns the verdict back to the API
  9b) If `verify` receives a failure, it tallies up all of the checks' severities and compares it to the `LOCKOUT_THRESHOLD`, locking the user out if necessary, and returns the verdict back to the API.
  10) Depending on the verdict, the API returns various success and failure responses to the client
  11) If the client receives a successful verdict, it calls `app/controllers/web/v3/gifts/verify` again (starting over at step #2)
  12) This continues until the client receives a :pass, :lockout, or :expired response, either calling the actual purchase API next, or displaying a lockout/expired notice to the user.


Here's the API call flows: (simplified)
(All attempts start with `verify` and branch from there.)
  * `app/controllers/web/v3/gifts/verify`  -> response: {verdict: pass/check/defer/lockout}
    - pass:     `app/controllers/web/v3/gifts#create`  (actually purchase the gift and stop)
    - check:    `app/controllers/web/v3/gifts/verify_response`
    - defer:    `app/controllers/web/v3/gifts/verify_sms_resume`  (user doesn't have a phone number to text a code to)
    - lockout:  none
  * `app/controllers/web/v3/gifts/verify_sms_resume`  -> response: {verdict: check/defer}
    - check:    `app/controllers/web/v3/gifts/verify_response`
    - defer:    `app/controllers/web/v3/gifts/verify_sms_resume`  (user still doesn't have a phone number)
  * `app/controllers/web/v3/gifts/verify_response`  -> response: {verdict: pass/failed/expired/lockout}
    - pass:     `app/controllers/web/v3/gifts#verify`
    - failed:   `app/controllers/web/v3/gifts#verify_response`
    - expired:  none
    - lockout:  none
  


Adding rules to the PV system is ridiculously easy:
  1) Add the rule name to the rules array in `PVRules.perform`
  2) Add a method named "rule_`new_rule_name`" that accepts a PV object.  This method should perform whatever logic you need, e.g. check if the user has uploaded any bad credit cards in the past month.
  2a) If the user/purchase passed the rule, return nil
  2b) If the user/purchase failed the rule (six bad credit cards), instead return a symbol indicating the verdict or check to run, such as :lockout or :sms_check.  This symbol is the name of the method to run; they're defined immediately below the rule methods.
  3) You're done!

Adding a new type of check to the PV system is also very easy:
  1) Add a new verdict method to PVRules (immediately below the rule methods).  This method will handle all of the logic of your check.  This could be e.g. IDology.  (Adding the new check is easy; writing the check itself might not be.)
  2) Add severity and credit values for your new check type to the top of the PVCheck model (to `FAIL_SEVERITY` and `PASS_SEVERITY`, respectively).
  3) Add a method (in the verifications section of the PVCheck model) to verify the user's response to your new check.  This should be named "_verify_`check_type`" and should accept the user's response.
  3a) This method should update the current PVCheck record's verified_at/failed_at/etc. and return a hash with {verdict:, success:}.  To make this much easier and avoid repetition, you can instead call a verdict method such as `pass!`/`fail!`/`defer`/`lockout!` that does all of this for you.  (FYI: The `!` on methods indicates that they perform another action, such as updating the current PVCheck record, before returning their data)
  3b) The default, of course, should be `fail!`
  4) You're done!

**IMPORTANT:**
> The mobile app and widgets DO NOT call `app/controllers/web/v3/gifts#verify()` again after failed checks; they instead keep calling `app/controllers/web/v3/gifts#verify_response()` a second, third, etc. time.  To handle this, when a user fails a type of check they should be able to re-attempt, you need to duplicate the current PVCheck record and then mark the original as failed.  Doing this creates a new, pending PVCheck record for the user to verify on their next attempt, and also saves their failure for lockout tallying.  To clarify: calling e.g. `self.dup.update(hex_id: nil, failed_at: nil, response: nil, result: nil)` (see here: `app/models/purchase_verification_check.rb` on line 205) duplicates the current PVCheck, scrubs it, and writes it to the db to await the user's next attempt.  Afterwards, `return fail!` marks the current PVCheck as failed and passes the failure verdict back to the client.






Database Schema
===============
  * `affiliates` List of affiliates, which are basically "super merchants" like GolfNow.  Also used for paying individuals (e.g. celebrity chefs) a commission for each merchant they sign up.
  * `affiliates_gifts`
  * `affiliations`
  * `alerts` The different types of alerts
  * `alert_contacts` Who gets alerts, which type of alert, and which "note" (or object) the alert pulls data from.
  * `alert_messages` A copy of each alert sent
  * `answers` The pair to `questions`, this is from an old, deprecated "question and answer" system where users could answer personal questions for rewards.  Failed data-mining endeavor.
  * `app_contacts` This stores users contacts from the app.
  * `at_users` AdminTools user accounts
  * `at_users_socials` Email/phone/etc. contacts for AdminTools users
  * `attachinary_files`
  * `banks` Merchant bank info
  * `bookings` Experience bookings
  * `books` I don't know.
  * `boomerangs`
  * `brands`
  * `bulk_contacts` From a failed 'bulk contact upload' feature from the App.  Failed data-mining venture.
  * `bulk_emails` From a failed 'bulk contact upload' feature from the App.  Failed data-mining venture.
  * `campaign_items`
  * `campaigns`
  * `cards`
  * `clients` A generic term for API consumers.  Includes Clover devices, widgets, Epson printers, IOM iOS/Android mobile app, Surfboard, etc.
    - contains a "clicks" col that gives a general indication of usage amount.  Not very reliable, though, as it can increment multiple times for a single interaction.

  * `company_contacts`
  * `contact_messages`
  * `contacts`
  * `contents`
  * `credit_accounts`
  * `debts`
  * `dittos` Every user interaction has a copy stored here.  Useful for debugging, and potentially for legalities.
  * `epson_printers` This is used for the epson printer tracking feature
  * `friendships`
  * `gift_analytics`
  * `gift_items`
  * `gifts` Stores user gifts
    - hex_id prefix: `gf`
    - column `cat` (for category) contains a 3-digit number that describes the origin of the gift.  Three parts make up this number, as described below.  Example: a 100 cat is a gift IOM sent, and a 301 cat is a standard consumer regift.
      - 1xx: admin      (IOM -> consumer)
      - 2xx: merchant   (Merchant -> consumer)
      - 3xx: standard   (consumer -> consumer)
      - x5x: "Camp"     (No clue)
      - xx1: Regift     (e.g. a consumer receives a gift and sends it to someone else)
      - xx7: Boomerang  (No longer used, and no active boomerangs still exist; safe to ignore)
      - These are currently defined in config/initializers/constants.rb#150  (look for `GIFT_CAT`)

  * `invites`
  * `landing_pages`
  * `legals`
  * `licenses`  Legal service agreements / contracts, I think.
    - id: :uuid, default: uuid_generate_v4()

  * `list_graphs`
  * `list_items`
  * `list_steps`
  * `lists` Used to group merchants/locations/lists, such as all Las Vegas venues into the Las Vegas list.
  * `menu_items` Items on merchant menus
    - These items can also include bonus gift settings so they can send another gift (based on a `proto`) when purchased.  This also includes scheduling.

  * `menu_strings`
  * `menus` Merchant menus
    - These can be "controller" menus, meaning a menu shared across multiple merchants (for multi-redemption merchants)

  * `merchant_signups`
    - Written to by Surfboard (onboard.itson.me) and Clover signups.

  * `merchants` Restaurants, golf courses, etc.
    - hex_id prefix: `mt`

  * `merchants_regions` Links merchants with regions; still active as far as I can tell (so don't delete it), but it's no longer used.
  * `messages`
  * `mt_users` Merchant Tools user accounts
  * `oauths`
  * `operations`
  * `payables`
  * `payments`
  * `place_graphs`
  * `places`
  * `pn_tokens`
  * `print_queues`  Self-explanatory
    - id: :uuid, default: uuid_generate_v4()

  * `printer_recalls`  Stores the details of a recalled printer
  * `progresses`
  * `proto_joins` Very strange name for bonus gifts, created by duplicating a `proto` and adding the relevant user information, etc.
  * `protos` Bonus gift archetype, used for creating bonus gifts
  * `purchase_verification_checks` Contains the "checks" for a Purchase Verification conversation.  One PV can contain any number of PVChecks.  A PVCheck is an SMS verification code, IDology question, etc.
  * `purchase_verifications` Contains the purchase verification conversation between a buyer and IOM.  One PV per purchase.
  * `questions` The pair to `answers`, this is from an old, deprecated "question and answer" system where users could answer personal questions for rewards.  Failed data-mining endeavor.
  * `redemptions` Stores gift redemptions.  When a user interacts with a gift of theirs in really any way, it creates a redemption.  Examples: creating a printed gift cert, hand_delivery cert, or partially/fully-redeeming their gift.
    - hex_id prefix: `rd`
    - The `token` column stores the "redemption code" -- currently a 4/5 digit number displayed to the user (for v2 and clover?) and used for lookup/verification by the merchant.

  * `regions` List of regions, used with `merchants_regions`; still active as far as I can tell (so don't delete it), but it's no longer used.
  * `registers` Used by accounting.  Per Jon: "Think 'check register'"
  * `relationships`
  * `sales`
  * `sections`
  * `session_tokens` Login session tokens
  * `settings`
  * `shares`
  * `sms_contacts`
  * `socials`
  * `supply_items` The items IOM sells through order.itson.me (Surfboard)
  * `supply_orders` The orders placed by customers through order.itson.me
    - The framework surrounding this is very much not finished, and only barely functions.

  * `tags`
  * `user_access_codes` Used by v4 APIs and MTA: The codes that grant users MTA access to merchants, e.g. "six spicy squids"
  * `user_access_roles` Used by v4 APIs and MTA: The roles access codes can grant.  These amount to `[:employee, :manager, :admin]`, though there can be multiple roles for these, effectively allowing custom titles.
  * `user_accesses` Used by v4 APIs and MTA: Which users have which access level to which merchant.
  * `user_points` Part of a deprecated leaderboard system that awarded points for buying/sending/using gifts, referring users(?), etc.
  * `user_socials` Email addresses, phone numbers, Twitter IDs, Facebook IDs, etc. associated with users.
  * `users` Mobile app user accounts


Bash Aliases
============

```
# git
alias g="git"
alias gs="git status"
alias gls="git ls-files"
alias gl="git log"
alias ga="git add"
alias gaa="git add --all"
alias gap="git add -p"
alias gf="git fetch"
alias gp="git pull"
alias gm="git merge"
alias gd="git diff"
alias gdc="git diff --cached"
alias gc="git commit -m"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gpo="git push origin"
alias gpqa="git push qa qa:master"

function git-describe {
    git log | grep $1 -A 5
}
alias glc='git-describe '
alias gdesc='git-describe '


# Rails
alias r="rails"
alias b="bundle"
alias be="bundle exec"
alias berc="bundle exec rails console"
alias bers="bundle exec rails server"

# Rails server (per-application ports)
alias bers-merchant="bers -p 3000"
alias bers-drinkboard="bers -p 3001"
alias bers-admin="bers -p 3002"


# Heroku
alias h="heroku"
alias hr="heroku run"
alias hrrc="heroku run rails console"
alias hrrc-drinkboard="heroku run rails console --app drinkboard"
alias hrrc-drinkboardqa="heroku run rails console --app dbappdev"
alias hrrc-admintools="heroku run rails console --app admindb"
alias hrrc-admintoolsqa="heroku run rails console --app admindbdev"
alias hrrc-merchtools="heroku run rails console --app merchtools"
alias hrrc-merchtoolsqa="heroku run rails console --app merchtoolsdev"


# Heroku Logs
alias hl="heroku logs"
alias hl-drinkboard="heroku logs --app drinkboard"
alias hl-admintools="heroku logs --app admindb"
alias hl-merchtools="heroku logs --app merchtools"
alias hl-drinkboardqa="heroku logs --app dbappdev"
alias hl-admintoolsqa="heroku logs --app admindbdev"
alias hl-merchtoolsqa="heroku logs --app merchtoolsdev"

alias hlt="heroku logs -t"
alias hlt-drinkboard="heroku logs -t --app drinkboard"
alias hlt-admintools="heroku logs -t --app admindb"
alias hlt-merchtools="heroku logs -t --app merchtools"
alias hlt-drinkboardqa="heroku logs -t --app dbappdev"
alias hlt-admintoolsqa="heroku logs -t --app admindbdev"
alias hlt-merchtoolsqa="heroku logs -t --app merchtoolsdev"
```

(I've left the heroku cli scaling and maintenance bash functions as an exercise for the reader.)

