# encoding: UTF-8
=begin
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
=end

require File.expand_path('../lib/god_object/smuxi_hooks/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name    = "smuxi_hooks"
  gem.version = GodObject::SmuxiHooks::VERSION.dup
  gem.authors = ["Alexander E. Fischer"]
  gem.email   = ["aef@godobject.net"]
  gem.description = <<-DESCRIPTION
Plugin framework for the multi-protocol distributed chat client Smuxi.
  DESCRIPTION
  gem.summary  = "Plugin framework for the multi-protocol distributed chat client Smuxi."
  gem.homepage = "https://www.godobject.net/"
  gem.license  = "ISC"
  gem.has_rdoc = "yard"
  gem.extra_rdoc_files  = ["HISTORY.md", "LICENSE.md"]
  gem.rubyforge_project = nil

  `git ls-files 2> /dev/null`

  if $?.success?
    gem.files         = `git ls-files`.split($\)
  else
    gem.files         = `ls -1`.split($\)
  end

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_development_dependency('pry')
  gem.add_development_dependency('yard')
  gem.add_development_dependency('redcarpet')
end
