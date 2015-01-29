<?php

use Symfony\Component\ClassLoader\ApcClassLoader;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Debug\Debug;

// Define application environment
defined('SYMFONY_ENV') || define('SYMFONY_ENV', getenv('SYMFONY_ENV') ?: 'prod');
defined('SYMFONY_DEBUG') || define('SYMFONY_DEBUG', getenv('SYMFONY_DEBUG') ?: SYMFONY_ENV === 'dev');

$loader = require_once __DIR__ . '/../app/bootstrap.php.cache';

// true has to be string, because we receive string from getenv
if (SYMFONY_DEBUG == 'true') {
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

$kernel = new WebsiteKernel(SYMFONY_ENV, SYMFONY_DEBUG);
$kernel->loadClassCache();

if (SYMFONY_ENV != 'dev') {
    require_once __DIR__ . '/../app/WebsiteCache.php';
    $kernel = new WebsiteCache($kernel);
}

Request::enableHttpMethodParameterOverride();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
