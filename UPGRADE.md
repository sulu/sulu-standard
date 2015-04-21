# Upgrade

# 0.17.0

## Ladybug

The ladybug bundle have been removed in favour of the new
[Symfony VarDumper Component](http://symfony.com/blog/new-in-symfony-2-6-vardumper-component)

### Media

Fill up the database column `me_collection_meta.locale` with the translated language like: `de` or `en`. If you
know you have only added collections in only one language you can use following sql statement:

```sql
UPDATE `me_collection_meta` SET `locale` = 'de';
```

Due to this it is possible that one collection has multiple metadata for one language. You have to remove this
duplicates by hand. For example one collection should have only one meta for the language `de`.

The collection and media has now a specific field to indicate which meta is default. For this run following commands.

```bash
app/console sulu:upgrade:0.17.0:collections
app/console sulu:upgrade:0.17.0:media
```

### Contact and Account Security

The security checks are now also applied to contacts and accounts, make sure
that the users you want to have access have the correct permissions.

### Content

Behaviour of internal links has changed. It returns the link title for navigation/smartcontent/internal-link.

### Media Types

The media types are now set by wildcard check and need to be updated,
by running the following command: `sulu:media:type:update`.

### Media API Object

The `versions` attribute of the media API object changed from [array to object list](https://github.com/sulu-io/docs/pull/14/files).

### Contact

CRM-Components moved to a new bundle. If you enable the new Bundle everything should work as before.

BC-Breaks are:

 * AccountCategory replaced with standard Categories here is a migration needed
 
For a database upgrade you have to do following steps:

* The Account has no `type` anymore. This column has to be removed from `co_accounts` table.
* The table `co_account_categories` has to be removed manually.
* The table `co_terms_of_delivery` has to be removed manually.
* The table `co_terms_of_payment` has to be removed manually.
* `app/console doctrine:schema:update --force`

### Security

The names of some classes have changed like shown in the following table:

Old name                                                          | New name
------------------------------------------------------------------|--------------------------------------------------------------
Sulu\Bundle\SecurityBundle\Entity\RoleInterface                   | Sulu\Component\Security\Authentication\RoleInterface
Sulu\Component\Security\UserInterface                             | Sulu\Component\Security\Authentication\UserInterface
Sulu\Bundle\SecurityBundle\Factory\UserRepositoryFactoryInterface | Sulu\Component\Security\Authentication\UserRepositoryFactoryInterface
Sulu\Component\Security\UserRepositoryInterface                   | Sulu\Component\Security\Authentication\UserRepositoryInterface
Sulu\Bundle\SecurityBundle\Permission\SecurityCheckerInterface    | Sulu\Component\Security\Authorization\SecurityCheckerInterface

If you have used any of these interfaces you have to update them.

## 0.16.0

## Content Types

Time content types returns now standardized values (hh:mm:ss) and can handle this as localized string in the input
field.

For content you can upgrade the pages with:

```bash
app/console sulu:upgrade:0.16.0:time
```

In the website you should change the output if time to your format.

If you use the field in another component you should upgrade your api that it returns time values in format (hh:mm:ss).

## Security

Database has changed: User has now a unique email address. Run following command:

```bash
app/console doctrine:schema:update --force
```

## 0.15.0

### Sulu Locales

The Sulu Locales are not hardcoded anymore, but configured in the `app/config/config.yml` file:

```yml
sulu_core:
    locales: ["de","en"]
```

You have to add the locales to your configuration, otherwise Sulu will stop working.

### Internal Links

The internal representation of the internal links have changed, you have to run the following command to convert them:

```bash
app/console sulu:upgrade:0.15.0:internal-links
```

### Websocket Component

Websocket start command changed to `app/console sulu:websocket:run`. If you use xdebug on your server please start
websockets with `app/console sulu:websocket:run -e prod`.

Rename the parameters `content_preview_port` and `content_preview_url` to `websocket_port` and `websocket_url`.
Additionally remove 'ws://' at front and '/' at end from `websocket_url`.

Default behavior is that websocket turned of for preview, if you want to use it turn it on in the
`app/config/admin/config.yml` under:

```yml
 sulu_content:
     preview:
         mode: auto       # possibilities [auto, on_request, off]
         websocket: false # use websockets for preview, if true it tries to connect to websocket server,
                          # if that fails it uses ajax as a fallback
         delay: 300       # used for the delayed send of changes, lesser delay are more request but less latency
```

### HTTP Cache

The HTTP cache integration has been refactored. The following configuration
must be **removed**:

````yaml
sulu_core:
    # ...
    http_cache:
        type: symfonyHttpCache
````

The Symfony HTTP cache is enabled by default now, so there is no need to do
anything else. See the [HTTP cache
documentation](http://sulu.readthedocs.org/en/latest/reference/bundles/http_cache.html)
for more information.

### Renamed RequestAnalyzerInterface methods

The text "Current" has been removed from all of the request analyzer methods.
If you used the request analyzer service then you will probably need to update
your code, see: https://github.com/sulu-cmf/sulu/pull/749/files#diff-23

### Environment Variable
We are now using the `SYMFONY_ENV` instead of the `APP_ENV` environment variable. You have to update your
`web/.htaccess` file or your system environment variables.

## 0.14.0

* Role name is now unique
  * check roles and give them unique names
* Apply all permissions correctly, otherwise users won't be able to work on snippets, categories or tags anymore

## 0.13.0

* Remove `/cmf/<webspace>/temp` from repository
  * run `app/console doctrine:phpcr:node:remove /cmf/<webspace>/temp` foreach webspace

## 0.12.0

* Permissions have to be correct now, because they are applied
  * otherwise add a permission value of 120 for `sulu.security.roles`,
    `sulu.security.groups` and `sulu.security.users` to one user to change
    the settings in the UI
  * also check for the correct value in the `locale`-column of the `se_user_roles`-table
    * value has to be a json-string (e.g. `["en", "de"]`)
* Snippet content type defaults to all snippet types available instead of the
  default one
  * Explicitly define a snippet type in the parameters if this is not desired

## 0.11.0

* Remove the following lines from `app/config/config.yml`:

````yaml
    content:
        path: "%kernel.root_dir%/../vendor/sulu/sulu/src/Sulu/Bundle/ContentBundle/Content/templates"
        internal: true
        type: page
````

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
