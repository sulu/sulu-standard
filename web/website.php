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
$loader = new ApcClassLoader('sf2', $loader);
$loader->register(true);
*/

require_once __DIR__ . '/../app/website/AppKernel.php';
//require_once __DIR__.'/../app/AppCache.php';

$kernel = new AppKernel(APP_ENV, (APP_ENV == 'dev') ? true : false);
$kernel->loadClassCache();
//$kernel = new AppCache($kernel);
Request::enableHttpMethodParameterOverride();
$request = Request::createFromGlobals();
$response = $kernel->handle($request);
$response->send();
$kernel->terminate($request, $response);
