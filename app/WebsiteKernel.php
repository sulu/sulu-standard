<?php

require_once(__DIR__ . DIRECTORY_SEPARATOR . 'AbstractKernel.php');

class WebsiteKernel extends \AbstractKernel
{
    public function __construct($environment, $debug)
    {
        parent::__construct($environment, $debug);
        $this->setContext(self::CONTEXT_WEBSITE);
    }
}
