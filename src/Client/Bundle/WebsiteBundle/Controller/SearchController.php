<?php

namespace Client\Bundle\WebsiteBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Request;

class SearchController extends Controller
{
    public function queryAction(Request $request)
    {
        $query = $request->query->get('q', '');

        $metadataFactory = $this->get('massive_search.metadata.factory');
        $searchManager = $this->get('massive_search.search_manager');

        $hits = $searchManager->search($query, 'content');

        return $this->render('ClientWebsiteBundle:Search:query.html.twig', array(
            'query' => $query,
            'hits' => $hits,
        ));
    }
}
