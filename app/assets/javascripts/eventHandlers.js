  function clearAeonCheckboxes() {
    document.querySelectorAll(".aeon_checkbox[checked]").forEach((cbox) => cbox.removeAttribute("checked"));
    return false;
  }