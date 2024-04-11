// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"

import "arclight"

// TODO: Check if these are in use because they appear not to be

// window.clearAeonCheckBoxes  = function () {
//   Array.prototype.forEach.call(
//     document.getElementsByClassName('aeon_checkbox'),
//     function(checkbox) { checkbox.checked = false; }
//   );
// };

// // add this listener on page load to ensure we don't stack them up
// document.addEventListener("turbo:load", function(event) {
//   const aeonForm = document.querySelector("#aeon_form");
//   if (aeonForm) aeonForm.submit();
// });
