// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"

import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const context = require.context("arclight", true, /\.js$/)
application.load(definitionsFromContext(context))
