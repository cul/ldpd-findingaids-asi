// We are using custom JS for the blacklight range plugin functionality because jQuery is not globally available
// and we are only using a minimal implementation.

document.addEventListener('DOMContentLoaded', () => {
  // Remove .sr-only on this element because FontAwesome defines an .sr-only class and we don't want it to apply here
  document.querySelector(
    '.blacklight-date_range .range-limit-input-group input.btn.sr-only',
  ).classList.remove('sr-only');

  // Hide .more_facets
  document.querySelector('.blacklight-date_range .more_facets').classList.add('visually-hidden');
});
