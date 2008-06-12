### Heirarchical Sections

Sometimes you may need to encapsulate the output of some sections inside another one. An HTML
template, for example, will usually contain the page body inside the body tag of a more general
"header" template. To set this up, you use the following `sections` call:

    sections 'header', ['section1', 'section2', 'copyright']
    
You can then call these from your `header.erb` file as simple yields. Each yield renders
one section in the sub-list:

    <html>
      <body>
        <h1>Section 1</h1>
        <%= yield %>
        
        <h1>Section 2</h1>
        <%= yield %>
        
        <h1>Copyright</h1>
        <%= yield %>
      </body>
    </html>
    
Alternatively you can yield all sub-sections with the convenience call `all_sections` 
(in the following [Haml](http://haml.hamptoncatlin.com) example, yield param 's' 
contains the section name which would serve as the li's id attribute):

    %html
      %body
        %ol
          - all_sections do |s|
            %li{:id => s}= yield
    
