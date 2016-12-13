<?php

/*
 * This file is part of Sulu.
 *
 * (c) MASSIVE ART WebServices GmbH
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

/**
 * The admin kernel is for the backend.
 */
class AdminKernel extends \AbstractKernel
{
    /**
     * {@inheritdoc}
     */
    protected $name = 'admin';

    /**
     * @param string $environment
     * @param bool $debug
     */
    public function __construct($environment, $debug)
    {
        parent::__construct($environment, $debug);
        $this->setContext(self::CONTEXT_ADMIN);
    }

    /**
     * {@inheritdoc}
     */
    public function registerBundles()
    {
        $bundles = parent::registerBundles();
        $bundles[] = new Symfony\Bundle\SecurityBundle\SecurityBundle();
        $bundles[] = new FOS\RestBundle\FOSRestBundle();
        $bundles[] = new Bazinga\Bundle\HateoasBundle\BazingaHateoasBundle();
        $bundles[] = new Sulu\Bundle\AdminBundle\SuluAdminBundle();
        $bundles[] = new Sulu\Bundle\CollaborationBundle\SuluCollaborationBundle();
        $bundles[] = new Sulu\Bundle\PreviewBundle\SuluPreviewBundle();

        return $bundles;
    }
}
