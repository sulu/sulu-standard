<?php

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

        $hits = $searchManager
            ->createSearch(sprintf('state:published AND %s*', str_replace('"', '\\"', $query)))
            ->locale($locale)
            ->index('page')
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
}
