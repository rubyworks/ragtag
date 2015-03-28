# Example

Here is a large example.

Given a template:

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

And given a local binding:

    customer = OpenStruct.new
    customer.name = "John Roberts"
    customer.address = "555 Hobart St"
    customer.city = "Palm Bay"
    customer.state = "FL"
    customer.zip = "32709"
    customer.age = 65
    customer.tags = [ 'ruby', 'javascript' ]

    customer_class = customer.age > 60 ? 'senior' : 'normal'

Then result will be:

    <?xml version="1.0"?>
    <html>
    <body>
      <div class="senior">
        <h1>John Roberts</h1>

        <p>The customer is 65 year old.</p>

        <ul>
          <li>ruby</li>
        
          <li>javascript</li>
        </ul>

        <ul>
          <li>
            <b>r</b>
          
            <b>u</b>
          
            <b>b</b>
          
            <b>y</b>
          </li>
        
          <li>
            <b>j</b>
          
            <b>a</b>
          
            <b>v</b>
          
            <b>a</b>
          
            <b>s</b>
          
            <b>c</b>
          
            <b>r</b>
          
            <b>i</b>
          
            <b>p</b>
          
            <b>t</b>
          </li>
        </ul>

        <b class="notice">
          The customer is a senior citizen.
        </b>

        
          The customer is a senior citizen.
        
      </div>
    </body>
    </html>

