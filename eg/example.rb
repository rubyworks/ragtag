require 'ragtag'

template = %q{
<html>
<body>
  <div attr="class: customer_class">
    <h1 content="customer.name">John Doe</h1>

    <p>The customer is <span replace="customer.age" /> year old.</p>

    <ul each="customer.tags" do="tag">
      <li content="tag">Tag</li>
    </ul>

    <ul each="customer.tags" do="tag">
      <li each="tag.split(//)" do="x">
        <b content="x" />
      </li>
    </ul>

    <b class="notice" if="customer.age > 60">
      The customer is a senior citizen.
    </b>

    <div class="notice" if="customer.age > 60" omit="true">
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


xml = RagTag.compile(template, binding)

puts xml

