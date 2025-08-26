import '@hotwired/turbo-rails';
import 'bootstrap';
import '@github/auto-complete-element';
import 'blacklight-frontend';

// TODO: Use FontAwesome Kits
import '@fortawesome/fontawesome-pro/css/fontawesome.css';
import '@fortawesome/fontawesome-pro/css/light.css';
import '@fortawesome/fontawesome-pro/css/solid.css';

import '../autocomplete-setup';
import '../request-cart-setup';
import '../blacklight-range-limit';
import '../admin';
import loadMirador from '../src/mirador';

document.addEventListener('turbo:load', loadMirador);
