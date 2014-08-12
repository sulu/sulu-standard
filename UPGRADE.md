# Upgrade

## 0.6.0

* Refactored StructureExtensions (issue https://github.com/sulu-cmf/SuluContentBundle/issues/159)
  - change twig variables for seo and excerpt from `content.extensions.seo.data.title` to `content.ext.seo.title`
* Tags or categories which were used in xml-template should be removed and the data should be stored in excerpt tab
  - change twig variables from `content.categories` to `content.ext.excerpt.categories` same for tags
