<?php

namespace Client\Bundle\WebsiteBundle\Controller;

use Sulu\Bundle\SearchBundle\LocalizedSearchManager\LocalizedSearchManagerInterface;
use Sulu\Bundle\WebsiteBundle\Controller\WebsiteController;
use Sulu\Component\Rest\RequestParametersTrait;
use Sulu\Component\Webspace\Analyzer\RequestAnalyzerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class SearchController extends WebsiteController
{
    use RequestParametersTrait;

    public function queryAction(Request $request)
    {
        $query = $this->getRequestParameter($request, 'q', true);

        /** @var LocalizedSearchManagerInterface $searchManager */
        $searchManager = $this->get('sulu_search.localized_search_manager');

        /** @var RequestAnalyzerInterface $requestAnalyzer */
        $requestAnalyzer = $this->get('sulu_core.webspace.request_analyzer');
        $locale = $requestAnalyzer->getCurrentLocalization()->getLocalization();

        $hits = $searchManager->search($query, $locale, 'content');

        $data = $this->getAttributes(
            array(
                'query' => $query,
                'hits' => $hits
            )
        );

        return $this->render(
            'ClientWebsiteBundle:views:query.html.twig',
            $data
        );
    }
}
