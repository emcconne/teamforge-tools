teamforge-tools Cookbook
========================
TODO: This cookbook is for manipulating teamforge tools.  It DOES NOT install TeamForge, Subversion or any software products.


Requirements
------------
TODO: This cookbook makes extensive use of Ruby savon for creating and manipulating SOAP responses.  This gem should automatically be installed when this package is installed but if it doesn't...


To operate this package requires three things:  TeamForge url, username and password. It's recommended that you use an encryted data bag... but not required. They are passed as attributes.

% knife data bag show YOUR_RECIPE main
{
	"id": "main",
	"teamforge_url": "http://TEAMFORGE_URL",
	"teamforge_username": "YOUR_USERNAME",
	"teamforge_password": "YOUR_PASSWORD"
}

This can be loaded in a recipe with:

creds = data_bag_item("YOUR_RECIPE"", "main")

And to access the values:

creds['teamforge_url']
creds['teamforge_username']

Usage
-----
#### teamforge-tools::default


Just include `teamforge-tools` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[teamforge-tools]"
  ]
}
```

Currently only create and update for TeamForge Tracker artifacts is supported but more is hopefully on the way.

Example Usage
-------------
 teamforge_tools_artifact "tracker1428" do
 	action :create
 	teamforge_url "https://teamforge_website"
 	teamforge_username "benfranklin"
 	teamforge_password "lightening"
 	title "Test Artifact"
 	description "Test Description"
 	status "Pending"
 end

teamforge_tools_artifact "artf97879" do
	action :update 
	teamforge_url "https://teamforge_website"
	teamforge_username "benfrankline"
	teamforge_password "lightening"
	status "Pending"
	estimated_hours 10
	comment "This is a great comment from Old Ben"
end

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Brent McConnell
