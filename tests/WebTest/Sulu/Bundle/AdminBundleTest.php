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

class AdminBundleTest extends WebDriverTestCase
{

    public static $browsers = array(
        array(
            'browserName' => 'firefox',
            'desiredCapabilities' => array(
                'host' => 'localhost',
                'port' => '4445',
                'platform' => 'Windows 2012',
            )
        ),
        array(
            'browserName' => 'chrome',
            'desiredCapabilities' => array(
                'host' => 'localhost',
                'port' => '4445',
                'platform' => 'Windows 2012'
            )
        ),
        /*array(
            'browserName' => 'firefox',
            'local' => true,
        ),*/
    );

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
