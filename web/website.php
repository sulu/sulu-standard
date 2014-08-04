<?php

use Symfony\Component\ClassLoader\ApcClassLoader;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Debug\Debug;

// Define application environment
defined('APP_ENV') || define('APP_ENV', (getenv('APP_ENV') ? getenv('APP_ENV') : 'prod'));

$loader = require_once __DIR__ . '/../app/bootstrap.php.cache';

if (APP_ENV == 'dev') {
    Debug::enable();
}

// Use APC for autoloading to improve performance.
// Change 'sf2' to a unique prefix in order to prevent cache key conflicts
// with other applications also using APC.
/*
$apcLoader = new ApcClassLoader('sf2', $loader);
$loader->unregister();
$apcLoader->register(true);
*/

require_once __DIR__ . '/../app/WebsiteKernel.php';

$kernel = new WebsiteKernel(APP_ENV, (APP_ENV == 'dev') ? true : false);
$kernel->loadClassCache();

if (APP_ENV != 'dev') {
    require_once __DIR__ . '/../app/WebsiteCache.php';
    $kernel = new WebsiteCache($kernel);
}

Request::enableHttpMethodParameterOverride();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
