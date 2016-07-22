<?php

/*
 * This file is part of Sulu.
 *
 * (c) MASSIVE ART WebServices GmbH
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

namespace Client\Bundle\WebsiteBundle\Controller;

use Massive\Bundle\SearchBundle\Search\SearchManagerInterface;
use Sulu\Bundle\WebsiteBundle\Controller\WebsiteController;
use Sulu\Component\Rest\RequestParametersTrait;
use Sulu\Component\Webspace\Analyzer\RequestAnalyzerInterface;
use Symfony\Component\HttpFoundation\Request;

class SearchController extends WebsiteController
{
    use RequestParametersTrait;

    public function queryAction(Request $request)
    {
        $query = $this->getRequestParameter($request, 'q', true);

        /** @var SearchManagerInterface $searchManager */
        $searchManager = $this->get('massive_search.search_manager');

        /** @var RequestAnalyzerInterface $requestAnalyzer */
        $requestAnalyzer = $this->get('sulu_core.webspace.request_analyzer');
        $locale = $requestAnalyzer->getCurrentLocalization()->getLocalization();
        $webspaceKey = $requestAnalyzer->getWebspace()->getKey();

        $queryString = '';
        if (strlen($query) < 3) {
            $queryString .= '+("' . self::escapeDoubleQuotes($query) . '") ';
        } else {
            $queryValues = explode(' ', $query);
            foreach ($queryValues as $queryValue) {
                if (strlen($queryValue) > 2) {
                    $queryString .= '+("' . self::escapeDoubleQuotes($queryValue) . '" OR ' .
                        preg_replace('/([^\pL\s\d])/u', '?', $queryValue) . '* OR ' .
                        preg_replace('/([^\pL\s\d])/u', '', $queryValue) . '~) ';
                } else {
                    $queryString .= '+("' . self::escapeDoubleQuotes($queryValue) . '") ';
                }
            }
        }

        $hits = $searchManager
            ->createSearch($queryString)
            ->locale($locale)
            ->index('page_' . $webspaceKey . '_published')
            ->execute();

        $data = $this->getAttributes(
            [
                'query' => $query,
                'hits' => $hits,
            ]
        );

        return $this->render(
            'ClientWebsiteBundle:views:query.html.twig',
            $data
        );
    }

    private static function escapeDoubleQuotes($query)
    {
        return str_replace('"', '\\"', $query);
    }
}
