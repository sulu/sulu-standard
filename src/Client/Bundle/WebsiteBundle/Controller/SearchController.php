<?php

namespace Client\Bundle\WebsiteBundle\Controller;

use Sulu\Bundle\SearchBundle\LocalizedSearchManager\LocalizedSearchManagerInterface;
use Sulu\Component\Rest\RequestParametersTrait;
use Sulu\Component\Webspace\Analyzer\RequestAnalyzerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class SearchController extends Controller
{
    use RequestParametersTrait;

    public function queryAction(Request $request)
    {
        $query = $this->getRequestParameter($request, 'q', true);
        $locale = $this->getRequestParameter($request, 'l', true);

        /** @var LocalizedSearchManagerInterface $searchManager */
        $searchManager = $this->get('sulu_search.localized_search_manager');

        /** @var RequestAnalyzerInterface $requestAnalyzer */
        $requestAnalyzer = $this->get('sulu_core.webspace.request_analyzer');

        $hits = $searchManager->search($query, $locale, 'content');

        return $this->render(
            'ClientWebsiteBundle:views:query.html.twig',
            array(
                'query' => $query,
                'hits' => $hits,
                'webspaceKey' => $requestAnalyzer->getCurrentWebspace()->getKey(),
                'locale' => $locale
            )
        );
    }
}
