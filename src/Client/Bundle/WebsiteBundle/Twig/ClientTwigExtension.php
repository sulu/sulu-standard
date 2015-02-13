<?php
/*
 * This file is part of the Sulu CMS.
 *
 * (c) MASSIVE ART WebServices GmbH
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

namespace Client\Bundle\WebsiteBundle\Twig;

/**
 * Class ClientTwigExtension
 */
class ClientTwigExtension extends \Twig_Extension
{
    /**
     * {@inheritdoc}
     */
    public function getName()
    {
        return 'client_website';
    }

    /**
     * Add your custom filters here
     */
    public function getFilters()
    {
        return array();
    }

    /**
     * Add your custom functions here
     */
    public function getFunctions()
    {
        return array();
    }

    // Add here some custom twig extensions
}
