<?php

use Symfony\Component\HttpKernel\Kernel;
use Symfony\Component\Config\Loader\LoaderInterface;

/**
 * The abstract kernel holds everything that is common between
 * AdminKernel and WebsiteKernel
 */
abstract class AbstractKernel extends Kernel
{
    private $context = null;

    const CONTEXT_ADMIN = 'admin';
    const CONTEXT_WEBSITE = 'website';

    /**
     * {@inheritDoc}
     */
    public function registerBundles()
    {
        $bundles = array(
            new Symfony\Bundle\AsseticBundle\AsseticBundle(),
            new Symfony\Bundle\FrameworkBundle\FrameworkBundle(),
            new Symfony\Bundle\MonologBundle\MonologBundle(),
            new Symfony\Bundle\SecurityBundle\SecurityBundle(), // admin only
            new Symfony\Bundle\SwiftmailerBundle\SwiftmailerBundle(),
            new Symfony\Bundle\TwigBundle\TwigBundle(),

            new Symfony\Cmf\Bundle\CoreBundle\CmfCoreBundle(),
            new Symfony\Cmf\Bundle\RoutingBundle\CmfRoutingBundle(), // website only

            new Doctrine\Bundle\DoctrineBundle\DoctrineBundle(),
            new Doctrine\Bundle\FixturesBundle\DoctrineFixturesBundle(),
            new Doctrine\Bundle\PHPCRBundle\DoctrinePHPCRBundle(),

            new FOS\RestBundle\FOSRestBundle(),
            new Bazinga\Bundle\HateoasBundle\BazingaHateoasBundle(), // admin only
            new JMS\SerializerBundle\JMSSerializerBundle(),
            new Liip\ThemeBundle\LiipThemeBundle(),
            new Sensio\Bundle\FrameworkExtraBundle\SensioFrameworkExtraBundle(),
            new Stof\DoctrineExtensionsBundle\StofDoctrineExtensionsBundle(),

            new Sulu\Bundle\AdminBundle\SuluAdminBundle(), // admin only
            new Sulu\Bundle\CategoryBundle\SuluCategoryBundle(),
            new Sulu\Bundle\ContactBundle\SuluContactBundle(),
            new Sulu\Bundle\ContentBundle\SuluContentBundle(),
            new Sulu\Bundle\CoreBundle\SuluCoreBundle(),
            new Sulu\Bundle\MediaBundle\SuluMediaBundle(),
            new Sulu\Bundle\SecurityBundle\SuluSecurityBundle(),
            new Sulu\Bundle\TagBundle\SuluTagBundle(),
            new Sulu\Bundle\TranslateBundle\SuluTranslateBundle(),
            new Sulu\Bundle\WebsiteBundle\SuluWebsiteBundle(),
            new Sulu\Bundle\LocationBundle\SuluLocationBundle(),

            new Client\Bundle\WebsiteBundle\ClientWebsiteBundle(),
        );

        if (in_array($this->getEnvironment(), array('dev', 'test'))) {
            $bundles[] = new Symfony\Bundle\WebProfilerBundle\WebProfilerBundle();
            $bundles[] = new Sensio\Bundle\DistributionBundle\SensioDistributionBundle();
            $bundles[] = new Sensio\Bundle\GeneratorBundle\SensioGeneratorBundle();
            $bundles[] = new Sulu\Bundle\GeneratorBundle\SuluGeneratorBundle();

            // Debug
            $bundles[] = new RaulFraile\Bundle\LadybugBundle\RaulFraileLadybugBundle();
        }

        return $bundles;
    }

    /**
     * {@inheritDoc}
     */
    public function registerContainerConfiguration(LoaderInterface $loader)
    {
        $loader->load(__DIR__ . '/config/' . $this->getContext() . '/config_' . $this->getEnvironment() . '.yml');
    }

    /**
     * {@inheritDoc}
     */
    public function getCacheDir()
    {
        return $this->rootDir.'/cache/' . $this->getContext() . '/'.$this->environment;
    }

    /**
     * Return the application context.
     *
     * The context indicates to the runtime code which
     * front controller has been accessed (e.g. website or admin)
     */
    protected function getContext()
    {
        if (null === $this->context) {
            throw new \RuntimeException(sprintf(
                'No context has been set for kernel "%s"', get_class($this)
            ));
        }

        return $this->context;
    }

    /**
     * Set the context
     */
    protected function setContext($context)
    {
        $this->context = $context;
    }
}
