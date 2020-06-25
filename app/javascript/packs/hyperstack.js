// Import all the modules
import React from 'react';
import ReactDOM from 'react-dom';

import {parse,stringify} from 'scss-parser';
import createQueryWrapper from 'query-ast';
import parseUnit from 'parse-unit'
 // for opal/hyperloop modules to find React and others they must explicitly be saved
// to the global space, otherwise webpack will encapsulate them locally here
global.React = React;
global.ReactDOM = ReactDOM;

global.parse = parse;
global.stringify = stringify;
global.createQueryWrapper = createQueryWrapper;
global.parseUnit = parseUnit;