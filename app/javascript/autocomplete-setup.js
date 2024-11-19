function submitSearchBarForm(e) {
  e.target.closest('form').submit();
}
document.addEventListener('turbo:load', () => {
  document.querySelector('auto-complete').addEventListener('auto-complete-change', submitSearchBarForm);
});
document.addEventListener('turbo:before-render', () => {
  document.querySelector('auto-complete').removeEventListener('auto-complete-change', submitSearchBarForm);
});
