#!/bin/bash

scss2css()
{
	sass --scss --sourcemap=none -t expanded scss/$1.scss:css/$1.css
}

echo [api_key_auth] Build css files from scss 

cd site/files
scss2css style
cd ../..

