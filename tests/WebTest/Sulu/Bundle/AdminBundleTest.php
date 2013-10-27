<?php
/*
 * This file is part of the Sulu CMS.
 *
 * (c) MASSIVE ART WebServices GmbH
 *
 * This source file is subject to the MIT license that is bundled
 * with this source code in the file LICENSE.
 */

namespace WebTest\Sulu\Bundle;

use Sauce\Sausage\WebDriverTestCase;
use Sauce\Sausage\SauceTestCommon;

class AdminBundleTest extends WebDriverTestCase
{

    public static $browsers = array(
        array(
            'browserName' => 'firefox',
            //'host' => '%s:%s@localhost',
            //'port' => 4445,
            'desiredCapabilities' => array(
                'platform' => 'Windows 2012',
            )
        ),
        array(
            'browserName' => 'chrome',
            //'host' => '%s:%s@localhost',
            //'port' => 4445,
            'desiredCapabilities' => array(
                'platform' => 'Windows 2012',
            )
        ),
        /*array(
            'browserName' => 'firefox',
            'local' => true,
        ),*/
    );

    // TODO make abstract TestCase class
    public function setupSpecificBrowser($params)
    {

        if (getenv('SAUCE_USERNAME') && getenv('SAUCE_ACCESS_KEY')) {
            define(SAUCE_USERNAME, getenv('SAUCE_USERNAME'));
            define(SAUCE_ACCESS_KEY, getenv('SAUCE_ACCESS_KEY'));
        }

        SauceTestCommon::RequireSauceConfig();

        if (isset($params['host'])) {
            $params['host'] = sprintf($params['host'], SAUCE_USERNAME, SAUCE_ACCESS_KEY);
        }


        if (getenv('TRAVIS_JOB_NUMBER')) {

            $capabilities = array();

            $capabilities['tunnel-identifier'] = getenv('TRAVIS_JOB_NUMBER');
            $capabilities['build'] = getenv('TRAVIS_BUILD_NUMBER');
            $capabilities['tags'] = array('Travis-CI', 'PHP ' . phpversion());

            if (isset($params['desiredCapabilities'])) {
                $params['desiredCapabilities'] = array_merge(
                    $params['desiredCapabilities'],
                    $capabilities
                );
            } else {
                $params['desiredCapabilities'] = $capabilities;
            }
        }

        parent::setupSpecificBrowser($params);
    }

    public function setUpPage()
    {
        $this->url('http://localhost/admin/login');
    }

    public function testLoginFail()
    {
        $this->byId('username')->value('admin');
        $this->byId('password')->value('...');
        $this->byTag('button')->click();
        $driver = $this;

        $badCredentials = function () use ($driver) {
            return ($driver->byCssSelector('#login > div')->text() == 'Bad credentials');
        };

        $this->spinAssert('Bad credentials info never showed up!', $badCredentials);
    }

    public function testLogin()
    {
        $this->byId('username')->value('admin');
        $this->byId('password')->value('admin');
        $this->byTag('button')->click();
        $driver = $this;

        $header = function () use ($driver) {
            return $driver->byClassName('header')->displayed();
        };

        $this->spinAssert("Header never showed up!", $header);
    }
}
