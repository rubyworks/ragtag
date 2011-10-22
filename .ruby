---
source:
- meta/
authors:
- name: Thomas Sawyer
  email: transfire@gmail.com
copyrights:
- holder: RubyWorks
  year: '2005'
  license: BSD-2-Clause
replacements: []
alternatives: []
requirements:
- name: nokogiri
- name: detroit
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
dependencies: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/ragtag.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/ragtag
  code: http://github.com/rubyworks/ragtag
  mail: http://groups.google.com/rubyworks-mailinglist
extra: {}
load_path:
- lib
revision: 0
created: '2005-11-26'
summary: A Ruby Template Attribute Language
title: RagTag
version: 0.6.0
name: ragtag
description: ! 'RagTag is a Ruby variation loosely based on Zope Page Templates and
  it''s TAL

  specification. It differs from ZPT in that it is specifically geared for use

  by Ruby.'
organization: rubyworks
date: '2011-10-22'
