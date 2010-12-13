--- 
name: ragtag
company: rubyworks
repositories: 
  public: git://github.com/rubyworks/ragtag.git
title: RagTag
contact: Trans <transfire@gmail.com>
requires: 
- group: []

  name: nokogiri
  version: 0+
- group: 
  - test
  name: syckle
  version: 0+
- group: 
  - test
  name: qed
  version: 0+
resources: 
  code: http://github.com/rubyworks/ragtag
  mail: http://groups.google.com/rubyworks-mailinglist
  home: http://rubyworks.github.com/ragtag
pom_verison: 1.0.0
manifest: 
- .ruby
- eg/example.rb
- lib/ragtag/core_ext/opvars.rb
- lib/ragtag.rb
- lib/ragtag.yml
- qed/01_syntax.rdoc
- qed/02_example.rdoc
- qed/applique/examples.rb
- HISTORY.rdoc
- LICENSE.txt
- README.rdoc
- VERSION
version: 0.6.0
copyright: Copyright (c) 2005 Thomas Sawyer
licenses: 
- Apache 2.0
description: RagTag is a Ruby variation loosely based on Zope Page Templates and it's TAL specification. It differs from ZPT in that it is specifically geared for use by Ruby.
summary: A Ruby Template Attribute Language
authors: 
- Thomas Sawyer
created: 2005-11-26
