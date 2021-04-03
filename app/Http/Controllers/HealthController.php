<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use RenokiCo\LaravelHealthchecks\Http\Controllers\HealthcheckController;

class HealthController extends HealthcheckController
{
    /**
     * Register the healthchecks.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return void
     */
    public function registerHealthchecks(Request $request)
    {
        $this->addHealthcheck('mysql', function (Request $request) {
            // Try testing the MySQL connection here
            // and return true/false for pass/fail.

            return true;
        });
    }
}
