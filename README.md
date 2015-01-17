Smuxi hooks API for Ruby
========================

[![Gem Version](https://badge.fury.io/rb/smuxi_hooks.png)](https://badge.fury.io/rb/smuxi_hooks)
[![Dependency Status](https://gemnasium.com/godobject/smuxi-hooks-ruby.png)](https://gemnasium.com/godobject/smuxi-hooks-ruby)
[![Code Climate](https://codeclimate.com/github/godobject/smuxi-hooks-ruby.png)](https://codeclimate.com/github/godobject/smuxi-hooks-ruby)

* [Documentation][docs]
* [Project][project]

   [docs]:    http://rdoc.info/github/godobject/smuxi-hooks-ruby/
   [project]: https://github.com/godobject/smuxi-hooks-ruby/

Description
-----------

Plugin framework for the multi-protocol distributed chat client Smuxi.

Features / Problems
-------------------

This project tries to conform to:

* [Semantic Versioning (2.0.0)][semver]
* [Ruby Packaging Standard (0.5-draft)][rps]
* [Ruby Style Guide][style]
* [Gem Packaging: Best Practices][gem]

   [semver]: http://semver.org/
   [rps]:    http://chneukirchen.github.com/rps/
   [style]:  https://github.com/bbatsov/ruby-style-guide
   [gem]:    http://weblog.rubyonrails.org/2009/9/1/gem-packaging-best-practices

Additional facts:

* Written purely in Ruby.
* Documented with YARD.
* Intended to be used with Ruby 1.9.3 or higher.
* Cryptographically signed git tags.

Shortcomings and problems:

* Currently, not all of the hooks that are available in Smuxi are supported.
* This library has NOT been tested extensively yet. With high probability
  there are errors hidden in the code, these errors might even have
  dangerous consequences for the security of your system. Please evaluate the
  code thoroughly before using it on a production system.

If you have solved any of these feel free to submit your changes back.

Requirements
------------

* Ruby 1.9.3 or higher

Installation
------------

On *nix systems you may need to prefix the command with `sudo` to get root
privileges.

### Gem

    gem install smuxi_hooks

Usage
-----

This documentation defines the public interface of the software. Don't rely
on elements marked as private. Those should be hidden in the documentation
by default.

This is still experimental software, even the public interface may change
substantially in future releases.

### Ruby interface

#### Loading

In most cases you want to load the code by using the following command:

~~~~~ ruby
require 'smuxi_hooks'
~~~~~

In a bundler Gemfile you should use the following:

~~~~~ ruby
gem 'smuxi_hooks'
~~~~~

#### Namespace

This project is contained within a namespace to avoid name collisions with
other code. If you do not want to specifiy the namespace explicitly you can
include it into the current scope by executing the following statement:

~~~~~ ruby
include GodObject::SmuxiHooks
~~~~~

#### Further information

See the `examples` directory for working plugin examples.

A custom plugin constists of only one file that can reside anywhere on the
filesystem where the Smuxi has access to it. Plugins could therefore easily
be published as separate gems.

Warning: Please make sure that Smuxi is not able to modify the plugin file.

To install a plugin on a Smuxi engine, you have to log into the user account,
the engine runs as:

  sudo -u smuxi examples/chat_logger.rb install

Same goes for uninstalling:

  sudo -u smuxi examples/chat_logger.rb uninstall

Hopefully I will find some time to write some more substantial documentation
soon.

Development
-----------

### Bug reports and feature requests

Please use the [issue tracker][issues] on github.com to let me know about errors
or ideas for improvement of this software.

   [issues]: https://github.com/godobject/smuxi-hooks-ruby/issues/

### Source code

#### Distribution

This software is developed in the source code management system Git. There are
several synchronized mirror repositories available:

* [GitHub][github] (located in California, USA)
    
    URL: https://github.com/godobject/smuxi-hooks-ruby.git

* [Gitorious][gitorious] (located in Norway)
    
    URL: https://git.gitorious.org/smuxi-hooks-ruby/smuxi-hooks-ruby.git

* [BitBucket][bitbucket] (located in Colorado, USA)
    
    URL: https://bitbucket.org/godobject/smuxi-hooks-ruby.git

* [Pikacode][pikacode] (located in France)

    URL: https://pikacode.com/godobject/smuxi-hooks-ruby.git

   [github]:    https://github.com/godobject/smuxi-hooks-ruby/
   [gitorious]: https://gitorious.org/smuxi-hooks-ruby/smuxi-hooks-ruby/
   [bitbucket]: https://bitbucket.org/godobject/smuxi-hooks-ruby/
   [pikacode]:  https://pikacode.com/godobject/smuxi-hooks-ruby/

You can get the latest source code with the following command, while
exchanging the placeholder for one of the mirror URLs:

    git clone MIRROR_URL

#### Tags and cryptographic verification

The final commit before each released gem version will be marked by a tag
named like the version with a prefixed lower-case "v", as required by Semantic
Versioning. Every tag will be signed by my [OpenPGP public key][openpgp] which
enables you to verify your copy of the code cryptographically.

   [openpgp]: https://aef.name/crypto/aef-openpgp.asc

Add the key to your GnuPG keyring by the following command:

    gpg --import aef-openpgp.asc

This command will tell you if your code is of integrity and authentic:

    git tag -v [TAG NAME]

#### Building gems

To package your state of the source code into a gem package use the following
command:

    rake build

The gem will be generated according to the .gemspec file in the project root
directory and will be placed into the pkg/ directory.

### Contribution

Help on making this software better is always very appreciated. If you want
your changes to be included in the official release, please clone the project
on github.com, create a named branch to commit, push your changes into it and
send a pull request afterwards.

Please make sure to write tests for your changes so that no one else will break
them when changing other things. Also notice that an inclusion of your changes
cannot be guaranteed before reviewing them.

The following people were involved in development:

* Alexander E. Fischer <aef@godobject.net>

License
-------

Copyright GodObject Team <dev@godobject.net>, 2015

This file is part of Smuxi hooks API for Ruby.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
