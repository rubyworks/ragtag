# RagTag Syntax

To demonstrate the RagTag syntax we first need to load the library.

    require 'ragtag'


## Content Rendering

Tag content can be rendered using the `content` attribute.

Given a template:

    <h1 content="name">John Doe</h1>

And given a local binding:

    name = 'Bill Hickcock'

Then result will be:

    <h1>Bill Hickcock</h1>


## Replacement

A tag can be fully replaced by a rendering using the `replace`
attribute.

Given a template:

    <p>The customer is <span replace="age" /> years old.</p>

And given a local binding:
 
    age = 40

The result will be:

    <p>The customer is 40 years old.</p>


## Atrtibute Rendering

To render variable attributes use the `attr` attribute.

Given a template:

    <div attr="class: sample" />

And given a local binding:

    sample = 'impressive'

The result will be:

    <div class="impressive"></div>


## Conditions

Conditional sections can be created using the `if` attribute.

Given a template:

    <b if="age >= 60">
      The customer is a senior citizen.
    </b>

And given a local binding:

    age = 60

The result will be:

    <b>
      The customer is a senior citizen.
    </b>


## Iteration

Iterations can be acheived via the `each` attribute.

Given a template:

    <ul each="tags" do="tag">
      <li content="tag">Tag</li>
    </ul>

And given a local binding:

    tags = ['ruby', 'perl', 'lua']

The result will be:

    <ul>
      <li>ruby</li>

      <li>perl</li>

      <li>lua</li>
    </ul>

