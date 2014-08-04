<?php

use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;

class AppKernel extends Kernel
{
    public function registerBundles()
    {
        $bundles = array(
            // enable symfony-standard bundles
            new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
            new Symfony\Bundle\TwigBundle\TwigBundle(),
            new Symfony\Bundle\MonologBundle\MonologBundle(),
            new Symfony\Bundle\SwiftmailerBundle\SwiftmailerBundle(),
            new Symfony\Bundle\AsseticBundle\AsseticBundle(),
            new Doctrine\Bundle\DoctrineBundle\DoctrineBundle(),
            new Sensio\Bundle\FrameworkExtraBundle\SensioFrameworkExtraBundle(),

            // enable helper bundles
            new FOS\RestBundle\FOSRestBundle(),
            new JMS\SerializerBundle\JMSSerializerBundle(),
            new Stof\DoctrineExtensionsBundle\StofDoctrineExtensionsBundle(),
            new Doctrine\Bundle\FixturesBundle\DoctrineFixturesBundle(),
            new Liip\ThemeBundle\LiipThemeBundle(),

            // enables sulu bundles
            new Sulu\Bundle\CoreBundle\SuluCoreBundle(),
            new Sulu\Bundle\ContactBundle\SuluContactBundle(),
            new Sulu\Bundle\WebsiteBundle\SuluWebsiteBundle(),
            new Sulu\Bundle\TagBundle\SuluTagBundle(),
            new Sulu\Bundle\CategoryBundle\SuluCategoryBundle(),
            new Sulu\Bundle\ContentBundle\SuluContentBundle(),
            new Sulu\Bundle\SecurityBundle\SuluSecurityBundle(),
            new Sulu\Bundle\MediaBundle\SuluMediaBundle(),
            new Sulu\Bundle\TranslateBundle\SuluTranslateBundle(),
            new Client\Bundle\WebsiteBundle\ClientWebsiteBundle(),
            new Sulu\Bundle\LocationBundle\SuluLocationBundle(),

            // enable cmf bundles
            new Doctrine\Bundle\PHPCRBundle\DoctrinePHPCRBundle(),
            new Symfony\Cmf\Bundle\CoreBundle\CmfCoreBundle(),
            new Symfony\Cmf\Bundle\RoutingBundle\CmfRoutingBundle(),
        );

        if (in_array($this->getEnvironment(), array('dev', 'test'))) {
            $bundles[] = new Symfony\Bundle\WebProfilerBundle\WebProfilerBundle();
            $bundles[] = new Sensio\Bundle\DistributionBundle\SensioDistributionBundle();
            $bundles[] = new Sensio\Bundle\GeneratorBundle\SensioGeneratorBundle();
            $bundles[] = new Sulu\Bundle\GeneratorBundle\SuluGeneratorBundle();
        }

        return $bundles;
    }

    public function registerContainerConfiguration(LoaderInterface $loader)
    {
        $loader->load(__DIR__ . '/config/config_' . $this->getEnvironment() . '.yml');
    }
}
