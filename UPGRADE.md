# Upgrade

## unreleased

* ...

## 0.10.0

* Smart-Content Pagination: introduced page and hasNextPage view vars
  - see commit https://github.com/sulu-cmf/sulu-standard/commit/e5f7f8e520ac8199b71bbd337c7f2df5ae3a85f4
* Smart-Content filters current page

## 0.9.0

* Every template must have a title property
  - Therefore the tag `sulu.node.name` doesn't have to be set anymore
* Page templates are stored in `app/Resources/pages` instead of `app/Resources/templates`
* config: default_type has now a sub-properties `page` and `snippet`
  - change `default_type: <name>` to `default_type: page: <name>`
* config: replace `sulu_core.content.templates` with `sulu_core.content.structure`
* PHPCR Node-types: Additional node types added 
  - run `app/console sulu:phpcr:init`
  - and `app/console sulu:webspaces:init`
  - and `app/console doctrine:phpcr:nodes:update --query="SELECT * FROM [nt:base] AS c WHERE [jcr:mixinTypes]='sulu:content'" --apply-closure="\$node->addMixin('sulu:page');"`
* URL pre-caching: URL now stored in node to load current URL fast
  - execute command `app/console sulu:upgrade:0.9.0:resource-locator`

## 0.8.2
  - add `ghost_script_path` parameter to app/conifg/parameters.yml

## 0.8.0

* navigation and sitemap changed interface and returned data
  - See the documentation for twig extensions: https://github.com/sulu-cmf/docs/blob/master/developer-documentation/300-webspaces/twig-extensions.md
  - Data which is returned contains only special values like
     + uuid
     + title
     + url
     + template
     + changed / changer / created / creator
     + template
     + nodeType
     + path
     + excerpt.* (load-excerpt= true)
     + children (if tree functions called)
* SmartContent and Internal Links
  - Supports "natural order". Existing systems need to run the `$ php app/console sulu:build node_order` command to migrate.
  - Configure returned values in xml-templates
  - Use configured "property-names" to get data
  - See documentation for smart-content: https://github.com/sulu-cmf/docs/blob/master/developer-documentation/300-webspaces/smart-content.md
* `.data` can now be removed from everywhere
* Search - Changes in template configuration:
  - The `<indexField>` has been replaced by `<tag name="..." role="..."/>` see the SearchBundle UPGRADE.md for more information.
* Breadcrumb items interface changed: id > uuid

## 0.7.0

* changed variables for twig template
  - see commit https://github.com/sulu-cmf/sulu-standard/commit/51cb276be9ea9bc7f402dfced1b92c6ac2c05cce and documentation at https://github.com/sulu-cmf/docs/blob/master/developer-documentation/300-webspaces/templates.md
* removed file extension from view-element in xml template
  - use `ClientWebsiteBundle:templates:example` instead of `ClientWebsiteBundle:templates:example.html.twig`
* navigation in webspace configuration
  - include navigation xml tag from dist file (sulu_io.xml.dist) and remove the nav-contexts from config file

## 0.6.0

* Kernel retructuring
  - execute the installation again up to the folder permissions and then update the database
* Refactored StructureExtensions (issue https://github.com/sulu-cmf/SuluContentBundle/issues/159)
  - change twig variables for seo and excerpt from `content.extensions.seo.data.title` to `content.ext.seo.title`
* Tags or categories which were used in xml-template should be removed and the data should be stored in excerpt tab
  - change twig variables from `content.categories` to `content.ext.excerpt.categories` same for tags
* Navigation
  - Use the `root_navigation` twig extension instead of the `navigation` variable in the twig templates
