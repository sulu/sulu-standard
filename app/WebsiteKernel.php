<?php

/*
 * This file is part of Sulu.
 *
 * (c) MASSIVE ART WebServices GmbH
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

class WebsiteKernel extends \AbstractKernel
{
    /**
     * {@inheritdoc}
     */
    protected $name = 'website';

    /**
     * @param string $environment
     * @param bool $debug
     */
    public function __construct($environment, $debug)
    {
        parent::__construct($environment, $debug);
        $this->setContext(self::CONTEXT_WEBSITE);
    }

    /**
     * {@inheritdoc}
     */
    public function registerBundles()
    {
        $bundles = parent::registerBundles();
        $bundles[] = new Symfony\Cmf\Bundle\RoutingBundle\CmfRoutingBundle();

        return $bundles;
    }
}
