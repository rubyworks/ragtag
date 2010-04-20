require 'rtals'

xml = %q{
<html>
<body>
  <div rtal:attr="class: customer_class">
    <h1 rtal:content="customer.name">John Doe</h1>

    <p>The customer is <span rtal:replace="customer.age" /> year old.</p>

    <ul rtal:each="customer.tags" rtal:do="tag">
      <li rtal:content="tag">Tag</li>
    </ul>

    <ul rtal:each="customer.tags" rtal:do="tag">
      <li rtal:each="tag.split(//)" rtal:do="x">
        <b rtal:content="x" />
      </li>
    </ul>

    <b class="notice" rtal:if="customer.age > 60">
      The customer is a senior citizen.
    </b>

    <div class="notice" rtal:if="customer.age > 60" rtal:omit="true">
      The customer is a senior citizen.
    </div>
  </div>
</body>
</html>
}

require 'ostruct'

customer = OpenStruct.new
customer.name = "John Roberts"
customer.address = "555 Hobart St"
customer.city = "Palm Bay"
customer.state = "FL"
customer.zip = "32709"
customer.age = 65
customer.tags = [ 'ruby', 'javascript' ]

customer_class = customer.age > 60 ? 'senior' : 'normal'


rxml = RTAL.compile(xml, binding)

puts rxml

