function submitSearchBarForm(e: Event): void {
  const target = e.target as HTMLElement;
  target.closest('form')?.submit();
}

document.addEventListener('turbo:load', (): void => {
  document.querySelector('auto-complete')?.addEventListener('auto-complete-change', submitSearchBarForm);
});

document.addEventListener('turbo:before-render', (): void => {
  document.querySelector('auto-complete')?.removeEventListener('auto-complete-change', submitSearchBarForm);
});