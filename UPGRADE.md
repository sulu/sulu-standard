# Upgrade

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
     + children (if tree functions called)
* SmartContent
  - Supports "natural order". Existing systems need to run the `$ php app/console sulu:build node-order` command to migrate.
  - Configure returned values in xml-templates
  - Use configured "property-names" to get data
  - See documentation for smart-content: https://github.com/sulu-cmf/docs/blob/master/developer-documentation/300-webspaces/smart-content.md
* `.data` can now be removed from everywhere
* Search - Changes in template configuration:
  - The `<indexField>` has been replaced by `<tag name="..." role="..."/>` see the SearchBundle UPGRADE.md for more information.

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
