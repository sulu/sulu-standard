<?php

require_once(__DIR__ . DIRECTORY_SEPARATOR . 'AbstractKernel.php');

/**
 * The admin kernel is for the backend
 */
class AdminKernel extends \AbstractKernel
{
    public function __construct($environment, $debug)
    {
        parent::__construct($environment, $debug);
        $this->setContext(self::CONTEXT_ADMIN);
    }

    public function registerBundles()
    {
        $bundles = parent::registerBundles();
        $bundles[] = new Symfony\Bundle\SecurityBundle\SecurityBundle();
        $bundles[] = new Sulu\Bundle\AdminBundle\SuluAdminBundle();

        if (in_array($this->getEnvironment(), array('dev', 'test'))) {
            $bundles[] = new Sulu\Bundle\GeneratorBundle\SuluGeneratorBundle();
        }

        return $bundles;
    }
}
