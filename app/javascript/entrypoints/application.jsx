import '@hotwired/turbo-rails';
import 'bootstrap';
import '@github/auto-complete-element';
import 'blacklight-frontend';

import '../autocomplete-setup';
import '../request-cart-setup';
import '../blacklight-range-limit';
import loadMirador from '../src/mirador';

document.addEventListener('turbo:load', loadMirador);
